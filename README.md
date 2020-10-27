# Robot Framework DotfilesLibrary

- A library for using [Robot Framework](http://robotframework.org) to automate deploying dotfiles and other configurations.

## Usage

- Place the *source/DotfilesLibrary* folder somewhere in your python path, or pass its location to robot using its --pythonpath flag.

- `LinkDotfiles.py` is imported as a library in `DeployDotfiles.resource`, which also adds keywords for running commands interactively and installing from package managers.
    - This resource file can be imported to robot files to automate setup tasks for new systems, including dotrfiles deployment and package installation.

- The library can then be used within robot framework test suites.

## Status

- This library is currently under development.

- Documentation, more robust testing, and example use cases are a work in progress.