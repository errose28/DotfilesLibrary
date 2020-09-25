# Dotfiles Deployment with Robot Framework

## Python Library

- Implements linking methods:
    - shallow_link()
        - Ignores the path leading up to the file.
        - Creates a link with the file name directly under the target.
        - Links all top level files or directories in `working_dir` if no args given.
    - deep_link()
        - Appends the path leading up to the file to the target to make the path to the link.
        - Recursively searches `working_dir` for all files and deep links them all if no args given.

- Files/dirs can be ignored by calling the `add/remove_ignore` function of the library to modify its ignore list.

- Support file globbing in path names.

- Relative paths resolved based on current working dir.
    - This can be changed in Robot by robot util or driver.

- Library takes the following configs as optional ctor params, which also have setters:
    - target
        - Base directory for all links.
        - Defaults to user home.
    - ignore
        - List of files/dirs to ignore when linking.
        - Overridden if files are specified explicitly in link call.
        - Defaults to empty.
    - mode
        - How linking conflicts should be handled.
        - skip, replace, backup, interactive
        - defaults to skip.
        - In interactive, asks skip, backup, or replace for each conflict.
    - verbose
        - Print all actions to stdout, and log them to robot.
            - Need to figure out how to log to robot from within library.
        - Everything is logged anyways, only when verbose is on is that content alo printed.
        - Defaults to off.

## Robot Library

- All configurations are set via robot variables.
    - These vars are passed to the python library, and can be changed within robot at any time with setters.

- Regular commands are defined in robot library.

- Advanced linking commands are propogated from python library.

## Driver

- Implemented in python

- Use click for cli.

- Map standard cli flags to robot variables.
    - target
    - mode
    - verbose

- Passes variables to robot framework using -v option.

- Also can pass variables from robot var file directly to robot.
    - Choose a given file name (maybe robot already has one) that will be searched for to define vars in the current
    directory.
        - Example: Make the source arch/system have target /.
    - Choose a config file location that will always be checked for variables.
        - Since everything is converted to robot variables, this file can be sent directly to robot.

- Passes all extra args to robot.
    - Includes --only and --exclude for selecting packages/sources.
    - Includes --tag for only deploying packages with a given tag.

- Can be acceptance tested with robot itself.

## Dotfiles Layout

- Use same layout; with packages, setup scripts, and sources.

- Each source defines dots for a different system, and sources may be nested.
    - common
    - arch
        - user
        - system
    - macos

- Source is selected by passing the directory to robot, which will run all robot files within it.

- Each package's setup.robot has tests: Install, Link, <anything else>
    - TBD if order should matter here.

### Options for Handling Mutliple Systems

1. Sources can override and extend each other by deploying one before the other.
    - Example:
        - common has .vimrc, but no install command for vim.
        - arch and macos each have no .vimrc, but have install commands for vim only.

2. Use tags to denote OS specific commands.
    - Example:
        - common has vim package, and install commands for all OSes.
        - Each OS install is a test tagged with the operating system.

## Control Flow

- Driver -> Robot -> Package (setup.robot) -> Robot Resources File -> Python Library

## TODO

### Blockers

- Test link methods by explicitly specifying files or dirs.
    - Current tests just use *

### Non Blockers

- Link using relative paths.
    - Will need to change tests to check for relative paths.

- Make and test getters for all setters.

- Implement interactive mode.

- Implement verbose in python library.

- Test ignore semantics with files, directories, and globs.

- Implement driver.