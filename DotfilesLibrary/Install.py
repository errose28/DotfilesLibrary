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
        self._installer = ConfigVariables.INSTALLER.value
        self._install_methods = ConfigVariables.INSTALL_WITH.value

        if bool(self._installer) != bool(self._install_methods):
            logger.warn(f'{ConfigVariables.INSTALLER.name} and {ConfigVariables.INSTALL_WITH.name} should be set together. ' \
                'Nothing will be installed.')
        elif self._installer:
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
                f'{default_pkg_args} {alias_pkg_args}')
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
            logger.info(f'Running install command {cmd}')
            Interactive.interactive(*cmd)
        elif self._installer_type is self.InstallerType.MODULE:
            logger.info(f'Running install function `{self._installer.__name__}.{install_function}({", ".join(pkg_args)})`')
            getattr(self._installer, install_function)(*pkg_args)
        else:
            logger.info(f'Skipping install since no install script or module is defined')
