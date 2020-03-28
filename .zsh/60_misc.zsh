# auto loaded
# 色を使用
autoload -Uz colors
colors

# 補完
# autoload -Uz compinit
# compinit
## compinit is loaded in zinit
setopt auto_list
setopt auto_menu

autoload -Uz select-word-style
select-word-style default

# 複数ファイルのmv 例　zmv *.txt *.txt.bk
autoload -Uz zmv
alias zmv='noglob zmv -W'

# zsyle
## 補完後、メニュー選択モードになり左右キーで移動が出来る
zstyle ':completion:*:default' menu select=2

## 補完で大文字にもマッチ
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

## 区切り文字を指定
zstyle ':zle:*' word-chars " _-./;@"
zstyle ':zle:*' word-style unspecified