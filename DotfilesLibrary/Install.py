from typing import List, Iterable
from robot.api.deco import keyword
from  robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from .Misc import interactive

@keyword
def pacman_install(*packages: str, sudo=True):
    sudo_cmd = 'sudo' if sudo else ''
    _install([sudo_cmd, 'pacman', '--noconfirm', '-S'], packages, check_cmd=['pacman', '-Q'])

@keyword
def yay_install(*packages: str):
    _install(['yay', '--noconfirm', '-S'], packages, check_cmd=['yay', '-Q'])

@keyword
def nix_install(*names: str, attr=True):
    if attr:
        attrs_list = map(lambda attr: 'nixos.' + attr, names)
        _install(['nix-env', '--install', '--attr'], attrs_list)
    else:
        _install(['nix-env', '--install'], names)

@keyword
def pip_install(*packages: str, user=False):
    user_cmd = '--user' if user else ''
    _install(['pip', 'install', user_cmd], packages)

@keyword
def brew_install(*packages: str):
    _install(['brew', 'install'], packages)

@keyword
def brew_cask_install(*packages: str):
    _install(['brew', 'cask', 'install'], packages)

def _install(install_cmd: Iterable[str], packages: Iterable[str], check_cmd: Iterable[str] = None):
    for package in packages:
        if check_cmd:
            is_installed = (interactive(*check_cmd, package) == 0)
        else:
            is_installed = False

        if not is_installed:
            interactive(*install_cmd, package, fail_on_rc=True)
