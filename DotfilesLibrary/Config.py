from robot.libraries.BuiltIn import BuiltIn

MODE = 'MODE'
TARGET = 'TARGET'
INSTALLER = 'INSTALLER'

def value(name: str, default=None):
    return BuiltIn().get_variable_value('${' + name + '}', default)
