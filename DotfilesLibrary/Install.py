from enum import Enum, auto
from typing import List, Any
from robot.api.deco import keyword, library
from robot.api import logger

from DotfilesLibrary import ConfigVariables, Interactive

@library(scope='SUITE')
class Install:
    class InstallerType(Enum):
        SCRIPT = auto()
        MODULE = auto()
        NONE = auto()

    def __init__(self):
        self._installer_type = self.InstallerType.NONE
        installer_value = ConfigVariables.INSTALLER.value
        if installer_value:
            self._installer, *self._install_methods = installer_value

            if not self._install_methods:
                logger.warn(f'{ConfigVariables.INSTALLER.name} specified without install methods, ' \
                    'nothing will be installed.')

            # If the install script is in the python path, it will be used as a module.
            # Else, it will be invoked as a script.
            try:
                self._installer = __import__(self._installer)
                self._installer_type = self.InstallerType.MODULE
                logger.info(f'{self._installer} found in the python path, and will be invoked as a module.')
            except ModuleNotFoundError:
                # Leave the installer as is, it wil be invoked as a script.
                self._installer_type = self.InstallerType.SCRIPT
                logger.info(f'{self._installer} not found in the python path, and will be invoked as a script.')

    @keyword
    def install(self, *default_pkg_args: str, **alias_pkg_args: Any):
        if self._installer_type is self.InstallerType.NONE:
            logger.info(f'{ConfigVariables.INSTALLER.name} not defined. Skipping `Install` keyword passed ' +
                '{default_pkg_args} {pkg_alias_args}')
            return

        for install_function in self._install_methods:
            pkg_args = alias_pkg_args.get(install_function, default_pkg_args)
            if pkg_args:
                if type(pkg_args) is str:
                    pkg_args = [pkg_args]
                self._install(install_function, pkg_args)
                break
            else:
                # If a falsy value was assigned to the installer, skip installation.
                logger.info(f'Installer {install_function} set to {pkg_args}, ignoring.')

    def _install(self, install_function: str, pkg_args: List[str]) -> None:
        if self._installer_type is self.InstallerType.SCRIPT:
            cmd = [self._installer, install_function, *pkg_args]
            logger.debug(f'Running install command `{cmd}`')
            Interactive.interactive(*cmd)
        elif self._installer_type is self.InstallerType.MODULE:
            logger.debug(f'Running install function `{self._installer}.{install_function}({", ".join(pkg_args)})`')
            getattr(self._installer, install_function)(*pkg_args)
        else:
            logger.debug(f'Skipping install since no install script or module is defined')