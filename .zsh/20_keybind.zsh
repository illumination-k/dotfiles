# default bind-ky
bindkey ";5C" forward-word
bindkey ";5D" backward-word

autoload -Uz is-at-least
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

# default bind-ky
bindkey "^A" beginning-of-line
bindkey "^B" backward-char
bindkey "^E" end-of-line
bindkey ";5C" forward-word
bindkey ";5D" backward-word


# cdr
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
fi

if has_cmd peco; then
    # peco function and key binds
    function peco-history-selection() {
        BUFFER=`history -n 1 | tac  | awk '!a[$0]++' | peco`
        CURSOR=$#BUFFER
        zle reset-prompt
    }

    zle -N peco-history-selection
    bindkey '^R' peco-history-selection

    # 移動履歴を参照して移動
    function peco-cdr () {
        local selected_dir="$(cdr -l | sed 's/^[0-9]\+ \+//' | peco --prompt="cdr >" --query "$LBUFFER")"
        if [ -n "$selected_dir" ]; then
            BUFFER="cd ${selected_dir}"
            zle accept-line
        fi
    }
    zle -N peco-cdr
    bindkey '^t' peco-cdr

    if has_cmd ghq; then
        function peco-ghq () {
            local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
            if [ -n "$selected_dir" ]; then
                if has_cmd code; then
                    BUFFER="code ${selected_dir}"
                else
                    BUFFER="cd ${selected_dir}"
                fi
                zle accept-line
            fi
            zle clear-screen
        }
        zle -N peco-ghq
        bindkey '^[g' peco-ghq
    fi
fi