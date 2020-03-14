# PROMPT settings

if type starship >/dev/null 2>&1; then
    echo "use starship prompt"
    eval "$(starship init zsh)"
else
    echo "use default zsh prompt"
    PROMPT="%(?.%{${fg[green]}%}.%{${fg[red]}%})%n${reset_color}@${fg[blue]}%m${reset_color}(%*%) %~
    %# "
    RPROMPT="%{${fg[blue]}%}[%~]%{${reset_color}%}"
    autoload -Uz vcs_info
    setopt prompt_subst
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
    zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
    zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
    zstyle ':vcs_info:*' actionformats '[%b|%a]'
    precmd () { vcs_info }
    RPROMPT=$RPROMPT'${vcs_info_msg_0_}'
fi