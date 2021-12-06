#!/usr/bin/env sh

# Simulate install commands by writing output to files instead.

installer1() {
    echo -n "$@" > /installer1.out
}

installer2() {
    echo -n "$@" > /installer2.out
}

installer3() {
    echo -n "$@" > /installer3.out
}

"$@"
