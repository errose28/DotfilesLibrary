from typing import List, Union
import os
from robot.libraries.BuiltIn import BuiltIn

class ConfigVariable:
    def __init__(self, name: str, default: str=None, sep: str=None):
        self._name = name
        self._default = default
        self._sep = sep

    @property
    def value(self) -> Union[str, List[str]]:
        """
        Returns the value of the variable if it is set. Otherwise, returns the default value. If the value is not set
        and there is no default value, returns None.
        """
        value = BuiltIn().get_variable_value('${' + self._name + '}', self._default)
        # If the variable was set but reset to empty or None, robot will not use the default value in the above call.
        if not value:
            value = self._default
        if isinstance(value, str) and self._sep:
            value = value.split(self._sep)
        return value

    @property
    def name(self) -> str:
        return self._name

# Configurations that can be set by the user.

MODE = ConfigVariable('MODE', default='skip')
TARGET = ConfigVariable('TARGET', default=os.path.expanduser('~'))
INSTALLER = ConfigVariable('INSTALLER')
INSTALL_WITH = ConfigVariable('INSTALL_WITH', sep=':')
