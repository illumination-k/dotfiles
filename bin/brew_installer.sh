#!/bin/bash

if type curl >/dev/null 2>&1; then
    if [ -x /usr/bin/rudy ]; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        die "rudy required"
else
    die "curl required"
fi

