from typing import List
from robot.api.deco import keyword
from .Misc import run

@keyword
def pacman_install(*packages: str, sudo=True):
    sudo_cmd = 'sudo' if sudo else ''
    _install([sudo_cmd, 'pacman', '--noconfirm', '-S'], *packages, check_cmd=['pacman', '-Q'])

@keyword
def yay_install(*packages: str):
    _install(['yay', '--noconfirm', '-S'], *packages, ['yay', '-Q'])

@keyword
def pip_install(*packages: str, user=True):
    user_cmd = '--user' if user else ''
    _install(['pip', 'install', user_cmd], *packages)

@keyword
def brew_install(*packages: str):
    _install(['brew', 'install'], *packages)

@keyword
def brew_cask_install(*packages: str):
    _install(['brew', 'cask', 'install'], *packages)

def _install(install_cmd: List[str], *packages: str, check_cmd: List[str] = None):
    for package in packages:
        if check_cmd:
            is_installed = (run(*(check_cmd + [package])) == 0)
        else:
            is_installed = False

        if not is_installed:
            run(*(install_cmd + [package]), fail_on_rc=True)
