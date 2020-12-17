# Accpetance Tests

## Layout

- Testing is done using robot framework inside a docker image.
    - This allows safe testing of installs and linking (which may move or replace files) on any platform.

- Source code for the tests can be found in the *robot* directory.
    - Shared test resources are in the *lib* directory.

## Running Tests

- Run `build.sh` to build the image used for testing.
    - This installs program dependencies on top of an arch linux image, so it does not need to be run when there are code changes.

- Run `test.sh` to run the acceptance tests inside the container.
    - Results will be printed to the console, and saved in a newly created *results* directory.

    - With no arguments, `test.sh` will run all tests.
        - Specific tests can be run by specifying their path relative to the docker compose directory.
            - Example: `test.sh robot/link` will run all link related tests.

    - To manually run tests and inspect results inside the container, pass the *-i* flag to *test.sh*
        - This places you in the testing container interactively, but does not run the robot tests.
        - You can manually run the tests in this mode from the */test/robot* directory in the container.

    - Containers will be automatically removed when the script exits.
