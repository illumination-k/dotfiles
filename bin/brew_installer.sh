#!/bin/bash

function die() {
	echo $@ >&2
	exit 1
}

if [[ $(uname) != "Darwin" ]]; then
	die "This os is not mac"
fi

cp ~/dotfiles/Brewfile ~

if type brew >/dev/null 2>&1; then
	echo "brew is already installed"
else
	if type curl >/dev/null 2>&1; then
		if [ -x /usr/bin/rudy ]; then
			/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		else
			die '/usr/bin/rudy required. if you want to use other ruby, please run `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`'
		fi
	else
		die "curl required"
	fi
fi

brew bundle
