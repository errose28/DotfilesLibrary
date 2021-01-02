from .Link import Link
from . import Install
from . import Misc

class DotfilesLibrary:
    def __init__(self, *args, **kwargs):
        self._link = Link(*args, **kwargs)

        # TODO: Use reflection to get functions from all modules.
        self._keywords = [
            Misc.interactive,
            Misc.enable_systemd_services,
            Install.nix_install,
            Install.pacman_install,
            Install.yay_install,
            Install.pip_install,
            Install.brew_install,
            Install.brew_cask_install,
            self._link.set_cwd,
            self._link.set_target,
            self._link.add_ignore,
            self._link.set_ignore,
            self._link.set_mode,
            self._link.shallow_link,
            self._link.deep_link
        ]

        for keyword in self._keywords:
            setattr(self, keyword.__name__, keyword)

    def get_keyword_names(self):
        return [keyword.__name__ for keyword in self._keywords]

