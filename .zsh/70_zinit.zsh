if [ ! -d ~/.zinit ]; then
    mkdir -p ~/.zinit
    git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit ice wait'!0'; zinit load zsh-users/zsh-syntax-highlighting
zinit ice wait'!0'; zinit load zsh-users/zsh-autosuggestions
zinit ice wait'!0'; zinit load zsh-users/zsh-completions

