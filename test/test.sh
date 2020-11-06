#!/usr/bin/env sh

if [ "$1" = '-i' ]; then
    # Run tests and place user interactively in container to inspect the results.
    docker-compose run --rm test_service /bin/sh
else
    # Run tests and display the results.
    docker-compose run --rm test_service
fi

