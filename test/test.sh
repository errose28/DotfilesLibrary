#!/bin/sh

if [ "$1" = '-i' ]; then
    docker-compose run --rm test_link /bin/sh
else
    docker-compose run --rm test_link
fi

