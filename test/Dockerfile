FROM ubuntu:latest

RUN apt-get update --fix-missing -y && \
    apt-get install -y curl && \
    curl -L https://raw.githubusercontent.com/illumination-k/dotfiles/master/bin/dependencies_installer.sh | bash