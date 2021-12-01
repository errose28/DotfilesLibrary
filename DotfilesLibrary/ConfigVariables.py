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
        value =  BuiltIn().get_variable_value('${' + self._name + '}', self._default)
        if value and self._sep:
            value = value.split(self._sep)
        return value

    @property
    def name(self) -> str:
        return self._name

# Configurations that can be set by the user

MODE = ConfigVariable('MODE', default='skip')
TARGET = ConfigVariable('TARGET', default=os.path.expanduser('~'))
INSTALLER = ConfigVariable('INSTALLER', sep=':')