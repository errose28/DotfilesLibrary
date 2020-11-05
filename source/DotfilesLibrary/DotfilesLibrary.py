from .Link import Link
from . import Install
from . import Misc

class DotfilesLibrary:
    def __init__(self, *args, **kwargs):
        self._link = Link(*args, **kwargs)

        # TODO: Use reflection to get functions from all modules.
        self._keywords = [
            Misc.run,
            Misc.enable_systemd_services,
            Install.pacman_install,
            Install.yay_install,
            Install.brew_install,
            Install.brew_cask_install,
            self._link.set_cwd,
            self._link.set_target,
            self._link.add_ignore,
            self._link.set_ignore,
            self._link.set_mode,
            self._link.set_verbose,
            self._link.shallow_link,
            self._link.deep_link
        ]

        for keyword in self._keywords:
            setattr(self, keyword.__name__, keyword)

    def get_keyword_names(self):
        return [keyword.__name__ for keyword in self._keywords]

    # def run_keyword(self, name, args):
    #     print(dir(self), file=sys.stderr)
    #     # return run(*args)
    #     return getattr(self, name)(*args)

    # def __getattr__(self, name):
    #     print('getattr', file=sys.stderr)
    #     return self._misc.run
        # if name == 'Run':
        #     return run
        # else:
        #     raise AttributeError()
