from typing import Tuple
from robot.libraries.BuiltIn import BuiltIn

MODE = 'MODE'
TARGET = 'TARGET'
INSTALLER = 'INSTALLER'

def get_value(name: str, default=None) -> str:
    return BuiltIn().get_variable_value('${' + name + '}', default)

def split_value(value: str, sep=':') -> Tuple[str]:
    return value.split(sep)
