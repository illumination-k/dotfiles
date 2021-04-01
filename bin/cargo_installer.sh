#!/bin/bash

if !(type "cargo" > /dev/null 2>&1); then
    if type curl >/dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    else
        die "curl required"
    fi
fi

if grep 'export PATH="$HOME/.cargo/bin:$PATH"' '.profile' >/dev/null; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> '.profile'
fi

libs=(exa bat ripgrep starship fd-find cargo-make cargo-readme)

for lib in ${libs[@]}; do
    if !(type $lib > /dev/null 2>&1); then
        echo "$lib is not installed"
        cargo install $lib
    fi
done