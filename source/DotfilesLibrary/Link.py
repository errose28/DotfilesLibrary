import os
from typing import Tuple, List
from pathlib import Path
import shutil
from enum import Enum
from robot.api.deco import keyword, library
from  robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

@library(scope='SUITE')
class Link:
    """
    Helper class to deploy dotfiles with symlinks using Robot Framework.
    the class operates on strings passed in by Robot, but converts them to pathlib.Path objects to work with internally.
    """

    class Mode(Enum):
        SKIP = 'skip'
        REPLACE = 'replace'
        BACKUP = 'backup'

    def __init__(self,
        cwd=None,
        target=None,
        ignore=None,
        mode=None,
        verbose=None):

        self._robot_file = self._value('SUITE SOURCE')

        self.set_cwd(cwd)
        self.set_target(target)
        self.set_ignore(ignore)
        self.set_mode(mode)
        self.set_verbose(verbose)

        # Do not link the setup file.
        self.add_ignore(self._robot_file)

    ### Setters ###

    @keyword
    def set_cwd(self, path: str) -> None:
        """
        Changes the current working directory.
        """
        if not path:
            path = os.path.dirname(self._robot_file)

        if path:
            os.chdir(path)
        # Else, keep current directory.

    @keyword
    def set_target(self, path: str) -> None:
        if not path:
            path = self._value('TARGET')
            if not path:
                path = os.environ['HOME']

        self._target = Path(path)

    @keyword
    def add_ignore(self, *paths: str) -> None:
        if paths:
            # Clear previous ignore value so it is not processed in _get_paths.
            old_ignore = self._ignore
            self._ignore = []
            self._ignore = old_ignore + self._get_paths(*paths)

    @keyword
    def set_ignore(self, *paths: str) -> None:
        # Clear previous ignore value so it is not processed in _get_paths.
        # Note that this will remove the robot file from the ignore list.
        self._ignore = []

        # Only add paths if the argument is not None or empty, and the first element is not None.
        if paths and paths[0]:
            self._ignore = self._get_paths(*paths)

    @keyword
    def set_mode(self, mode: str) -> None:
        # Sets mode based a string value using any case.
        if not mode:
            mode = self._value('MODE')
            if not mode:
                mode = 'skip'

        self._mode = self.Mode[mode.upper()]

    @keyword
    def set_verbose(self, verbose: bool) -> None:
        if verbose is None:
            verbose = self._value('VERBOSE')
            if verbose is None:
                verbose = False

        self._verbose = verbose

    ### Exposed Keyword Linking Methods ###

    @keyword
    def shallow_link(self, *paths: str) -> None:
        """
        For each path in paths, creates a symlink immediately under the target with the same name as the file or
        directory the path specifies. Files are linked using absolute paths. Raises ValueError if paths are not
        subidrectories of the current working directory.

        Example:
        target = '/target'
        shallow_link('/foo/bar')
        Resulting link: /target/bar -> /foo/bar
        """

        for path in self._get_paths(*paths):
            target_path = self._get_target(path)
            self._link(path, target_path)

    @keyword
    def deep_link(self, *paths: str) -> None:
        """
        For each path in paths, recursively searches for all files contained in each subdirectory, and creates a
        symlink in target contained in the file's subdirectories that points to each file. Raises ValueError if paths
        are not subidrectories of the current working directory.

        Example:
        target = '/target'
        shallow_link('/foo/bar')
        Resulting link: /target/foo/bar -> /foo/bar
        """
        for path in self._get_paths(*paths):
            if path.is_file():
                target_path = self._get_target(path)
                self._link(path, target_path)
            else:
                for root, _, files in os.walk(str(path)):
                    for file in files:
                        src_file = Path(root, file)
                        target_file = self._get_target(src_file)
                        self._link(src_file, target_file)

    ### Hidden Helper Methods ###

    def _get_target(self, path: Path) -> Path:
        """
        If path is contained in the current working directory, removes all directories from path after cwd and
        appends them to target to create the destination.
        If path is not contained in the current working directory, value error is thrown.
        """
        return self._target.joinpath(path.relative_to(os.getcwd()))

    def _link(self, src: Path, dst: Path) -> bool:
        """
        Creates a symlink with name dst that points to src.
        Symlink is only created if src is not ignored.
        If dst exists, symlink is only created if mode is not skip.
        If dst exists and mode is backup, a backup copy of dst will be created before replacing it with the link.
        """

        should_link = True

        if dst.exists():
            if self._mode == self.Mode.SKIP:
                should_link = False
                self._print_verbose('Skipping file ' + str(src) + ' whose destination ' + str(dst) + ' already exists.')
            else:
                if self._mode == self.Mode.BACKUP:
                    self._backup(dst)

                os.remove(dst)

        if should_link:
            # Make intermediate directories for symlink.
            os.makedirs(dst.parent, exist_ok=True)
            os.symlink(src, dst)
            self._print_verbose('Created link ' + str(dst) + ' pointing to ' + os.readlink(dst))

        return should_link

    def _is_ignored(self, path: Path) -> bool:
        """
        Determines if the given path is contained in the ignore list, either literally or within a subdirectory.
        Globbing in the ignore list is currently not supported.
        """
        is_ignored = False

        for ignore_path in self._ignore:
            if ignore_path.is_file():
                is_ignored = ignore_path.samefile(path)
            else:
                # Check match if the ignore path is a directory.
                is_ignored = True
                try:
                    # Path.relative_to throws ValueError if the parameter is not a subdirectory (not ignored).
                    path.relative_to(ignore_path)
                except ValueError:
                    is_ignored = False

            if is_ignored:
                break

        return is_ignored

    def _get_paths(self, *paths: Tuple[str]) -> List[Path]:
        """
        Converts paths to a list of pathlib.Path objects.
        Absolute paths are treated literally, relative paths are resolved to the current working directory,
        so that all path objects returned are absolute.
        File globs include * and ** are expanded and their results are added (includes hidden files).
        """

        path_list = []

        for path_str in paths:
            # Convert all paths to absolute.
            path = Path(path_str).resolve()
            # Cannot glob absolute paths, so make them relative to root, glob, then resolve back to the root.
            unglobbed_paths = Path(path.anchor).glob(str(path.relative_to(path.anchor)))

            for try_path in unglobbed_paths:
                if self._is_ignored(try_path):
                    self._print_verbose('Ignoring ' + str(try_path))
                else:
                    path_list.append(try_path)

        return path_list

    def _backup(self, path: Path) -> str:
        i = 0
        backup = path
        while backup.exists():
            i += 1
            backup = backup.parent / (backup.name + '~' + str(i) + '~')

        shutil.copyfile(path, backup)
        self._print_verbose('Backup of file ' + str(path) + ' created at ' + str(backup))

        return backup

    @staticmethod
    def _value(name, default=None):
        return BuiltIn().get_variable_value('${' + name + '}', default)

    def _print_verbose(self, msg: str) -> None:
        # TODO: Determine whether to keep verbose flag or just use robot's log levels.
        if self._verbose:
            logger.info(msg, also_console=True)
