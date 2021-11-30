from Link import Link
import Interactive

class DotfilesLibrary:
    def __init__(self, *args, **kwargs):
        self._link = Link(*args, **kwargs)

        # TODO: Use reflection to get functions from all modules.
        self._keywords = [
            Interactive.interactive,
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

