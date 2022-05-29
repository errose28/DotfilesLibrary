import os
from typing import Tuple, List
from pathlib import Path
import shutil
from enum import Enum
from robot.api.deco import keyword, library
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

from DotfilesLibrary import ConfigVariables

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
        mode=None):

        self._robot_file = BuiltIn().get_variable_value('${SUITE SOURCE}')

        self.set_cwd(cwd)
        self.set_target(target)
        self.set_ignore(ignore)
        self.set_mode(mode)

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
        logger.debug(f'cwd set to {path}')

    @keyword
    def set_target(self, path: str=None) -> None:
        # Passing an empty string or none should reset to the default value.
        if not path:
            path = ConfigVariables.TARGET.default

        self._target = Path(path).expanduser().resolve()
        logger.debug(f'target set to {self._target}')

    @keyword
    def add_ignore(self, *paths: str) -> None:
        if paths:
            # Clear previous ignore value so it is not processed in _get_paths.
            old_ignore = self._ignore
            self._ignore = []
            self._ignore = old_ignore + self._expand_paths(*paths)

        logger.debug(f'ignore set to {self._ignore}')

    @keyword
    def set_ignore(self, *paths: str) -> None:
        self._ignore = []
        # Only add paths if the argument is not None or empty, and the first element is not None.
        if paths and paths[0]:
            logger.debug('foo ' + str(type(paths[0])))
            self._ignore = self._expand_paths(*paths)
        # Re-add the current robot file to the ignore list after reseting the list.
        self.add_ignore(self._robot_file)

        logger.debug(f'ignore set to {self._ignore}')

    @keyword
    def set_mode(self, mode: str=None) -> None:
        # Sets mode based a string value using any case.
        if not mode:
            mode = ConfigVariables.MODE.default

        self._mode = self.Mode[mode.upper()]
        logger.debug(f'mode set to {mode}')

    ### Exposed Keyword Linking Methods ###

    @keyword
    def shallow_link(self, *paths: str) -> None:
        """
        For each path in paths, creates a symlink immediately under the target with the same name as the file or
        directory the path specifies. Files are linked using absolute paths. Ignore entries for paths inside a directory
        being shallow linked are diregarded. Raises ValueError if paths are not subdirectories of the current working
        directory.

        Example:
        target = '/target'
        shallow_link('/foo/bar')
        Resulting link: /target/bar -> /foo/bar
        """

        for path in self._expand_paths(*paths):
            if not path.exists():
                raise FileNotFoundError(f'Cannot shallow link {path} which not exist')
            if not self._is_ignored(path):
                target_path = self._get_target(path)
                self._link(path, target_path)

    @keyword
    def deep_link(self, *paths: str) -> None:
        """
        For each path in paths, recursively searches for all files contained in each subdirectory, and creates a
        symlink in target contained in the file's subdirectories that points to each file. Raises ValueError if paths
        are not subdirectories of the current working directory.

        Example:
        target = '/target'
        shallow_link('/foo/bar')
        Resulting link: /target/foo/bar -> /foo/bar
        """
        for path in self._expand_paths(*paths):
            if path.is_file():
                if not self._is_ignored(path):
                    target_path = self._get_target(path)
                    self._link(path, target_path)
            else:
                for root, _, files in os.walk(str(path)):
                    for file in files:
                        src_file = Path(root, file)
                        # Ignore list must be checked for each file. If we pass in the parent directory only, we may
                        # miss a child file that is being explicitly ignored.
                        if not self._is_ignored(src_file):
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
        If dst exists, symlink is only created if mode is not skip.
        If dst exists and mode is backup, a backup copy of dst will be created before replacing it with the link.
        """

        should_link = True

        if self._exists(dst):
            if self._mode == self.Mode.SKIP:
                should_link = False
                logger.info(f'Skipping file {src} whose destination {dst} already exists.')
            else:
                if self._mode == self.Mode.BACKUP:
                    self._backup(dst)
                elif self._mode != self.Mode.REPLACE:
                    raise ValueError(f'Unrecognized mode configured: {str(self._mode)}')

                # In replace or backup mode, remove conflicting file or directory recursively.
                if dst.is_dir():
                    shutil.rmtree(dst)
                else:
                    os.remove(dst)

        if should_link:
            # Make intermediate directories for symlink.
            os.makedirs(dst.parent, exist_ok=True)
            os.symlink(src, dst)
            logger.info(f'Created link {dst} pointing to {os.readlink(dst)}')

        return should_link

    @staticmethod
    def _exists(path: Path) -> bool:
        """
        Returns true if path exists as a regular file/dir, symlink, or broken symlink.
        Note that Path.exists() returns false for broken symlinks.
        """
        return path.exists() or (path.is_symlink() and not path.readlink().exists())

    def _is_ignored(self, path: Path) -> bool:
        """
        Determines if the given path matches a path in the ignore list.
        Path globs should be expanded before calling this method.

        if path is a file:
            This method returns true if path is a subdirectory of an ignored directory, or an exact match to an ignored
            file.
        if path is a directory:
            This method returns true if path is a subdirectory of an ignored directory, or an exact match to an ignored
            directory. It does not check file ignores.
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
                logger.debug(f'Ignoring {path} because it matches ignored path {ignore_path}')
                break

        return is_ignored

    def _expand_paths(self, *paths: Tuple[str]) -> List[Path]:
        """
        Converts paths to a list of pathlib.Path objects.
        Absolute paths are treated literally, relative paths are resolved to the current working directory,
        so that all path objects returned are absolute.
        File globs include * and ** are expanded and their results are added (includes hidden files).
        """

        path_list = []

        for path_str in paths:
            # Convert all paths to absolute and convert ~ to user home.
            path = Path(path_str).expanduser().resolve()
            # Cannot glob absolute paths, so make them relative to root, glob, then resolve back to the root.
            unglobbed_paths = Path(path.anchor).glob(str(path.relative_to(path.anchor)))
            prev_path_list_len = len(path_list)
            path_list += unglobbed_paths
            # If the generator did not have any items, the path given did not exist.
            # Note that we cannot query the size of the generator without expanding it.
            if len(path_list) == prev_path_list_len:
                raise FileNotFoundError(f'{path} does not exist or has no glob matches.')

        return path_list

    def _backup(self, path: Path) -> str:
        i = 0
        backup = path
        while backup.exists():
            i += 1
            backup = backup.parent / (backup.name + '~' + str(i) + '~')

        shutil.copyfile(path, backup)
        logger.info(f'Backup of file {path} created at {backup}')

        return backup
