# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Better support for package installation
    - `INSTALLER` config variable to specify script defining install commands.
    - `INSTALL_WITH` config variable to specify package manager info passed to `INSTALLER`.
    - `Install` keyword to specify packages or other arguments passed to `INSTALLER`.

## [0.1.0] - 2021-01-22

### Added

- Support for absolute symlink deploys with `Deep Link` and `Shallow Link`
    - Globbing support for arguments.

- Suite scoped setters for target directory, current working directory, and ignored files.

- `MODE` config variable to set method for resolving conflicting files in the target.
    - Supports `skip`, `backup`, or `replace` modes.
    - `backup` mode adds a non-configurabel suffix to the file name until a non-conflicting name is reached.

- `Interactive` keyword to run shell commands in the foreground.

- No-op `Emit` keyword that can be used with listeners for plugable operations.


[Unreleased]: https://github.com/errose28/DotfilesLibrary/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/errose28/DotfilesLibrary/releases/tag/v0.1.0