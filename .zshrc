if type zplug >/dev/null 2>&1; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi

source ~/.zplug/init.zsh

zplug "~/.zsh", from:local

source ~/.profile