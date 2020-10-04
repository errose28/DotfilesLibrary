# Rodots

- Use [Robot Framework](http://robotframework.org) to automate deploying dotfiles and other configurations.

## Implementation

- Symlinking of dotfiles is handled by `LinkDotfiles.py`.
    - This is a configurable Robot Framework library implemented in Python.

- `LinkDotfiles.py` is imported as a library in `DeployDotfiles.resource`, which also adds keywords for running commands interactively and installing from package managers.
    - This resource file can be imported to robot files to automate setup tasks for new systems, including dotrfiles deployment and package installation.

## Status

- This library is currently under development.

- Documentation, more robust testing, and example use cases are a work in progress.