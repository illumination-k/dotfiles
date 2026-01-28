#!/bin/bash
docker build -f docker/Dockerfile.nix-test -t dotfiles-nix-test .
docker run -it --rm -v $(pwd):/workspace dotfiles-nix-test
