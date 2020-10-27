#!/usr/bin/env sh

# Builds the image needed for testing.
# All code is mounted in docker-compose, so this should only need to be run once locally.
docker build --tag=robot-archlinux .
