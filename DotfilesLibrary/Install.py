from robot.api.deco import keyword, library
from robot.api import logger

from DotfilesLibrary import Config

@library(scope='SUITE')
class Install:
    def __init__(self):
        self._has_installer = False
        installer_value = Config.get_value(Config.INSTALLER)
        if installer_value:
            install_module_name, *self._install_functions = Config.split_value(installer_value)
            self._install_module = __import__(install_module_name)
            self._has_installer = True

    @keyword
    def install(self, default_pkg_name, **pkg_aliases):
        if not self._has_installer:
            logger.info(f'{Config.INSTALLER} not defined. Skipping install keyword passed ' +
                '{default_pkg_name} {pkg_aliases}')
            return

        for install_function in self._install_functions:
            pkg_name = pkg_aliases.get(install_function, default_pkg_name)
            # If a falsy value was assigned to the installer, skip installation but log a warning.
            if pkg_name:
                self._install(install_function, pkg_name)
                break
            else:
                logger.warn(f'Installer {install_function} set to {pkg_name}, ignoring.')

    def _install(self, install_method: str, pkg_name: str):
        logger.debug(f'Installing {pkg_name} using {self._install_module.__name__}.{install_method}')
        getattr(self._install_module, install_method)(pkg_name)
