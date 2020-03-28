# vim keybind
bindkey -v
bindkey "jj" vi-cmd-mode


if is-at-least 5.0.8; then
    # select-quoted
    autoload -U select-quoted
    zle -N select-quoted
    for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
    done

    # surround
    autoload -Uz surround
    zle -N delete-surround surround
    zle -N change-surround surround
    zle -N add-surround surround
    bindkey -a cs change-surround
    bindkey -a ds delete-surround
    bindkey -a ys add-surround
    bindkey -M visual S add-surround
fi
