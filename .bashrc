[ -z "$PS1" ] && return

##### History #####
# historyコマンドでの実行日時の記録
HISTTIMEFORMAT='%y/%m/%d %H:%M:%S '

# historyの保存件数の変更
HISTSIZE=10000

# share history
export PROMPT_COMMAND='history -a; history -r'

##### key bind (vim) #####
set -o vi
bind '"jj": vi-movement-mode'

##### ailias #####
# Common aliases
ostype() {
    echo $(uname)
}

os_detect() {
    export PLATFORM
    case "$(ostype)" in
        *'linux'*)  PLATFORM='linux'   ;;
        *'Darwin'*) PLATFORM='osx'     ;;
        *'bsd'*)    PLATFORM='bsd'     ;;
        *)          PLATFORM='unknown' ;;
    esac
}

if [[ $PLATFORM == osx ]]; then
  if [ -x /usr/local/bin/gdircolors ]; then
    if [ -f ~/.colorrc ]; then
      eval `gdircolors ~/.colorrc`
      alias ls='gls -F --color=auto'
      alias lsa='gls -aF --color=auto'
    else
      echo "colorrc does not exist"
      alias ls='gls -F --color=auto'
      alias lsa='gls -aF --color=auto'
    fi
  else
    echo "I recommend to install gdircolors and make colorrc"
    alias ls='ls -FG'
    alias lsa='ls -aFG'
  fi
elif [[ $PLATFORM == linux ]]; then
  if [ -f ~/.colorrc ]; then
    eval `dircolors ~/.colorrc`
  fi
  alias ls='ls -F --color=auto'
  alias lsa='ls -aF --color=auto'
else
  if [ -f ~/.colorrc ]; then
    eval `dircolors ~/.colorrc`
  fi
  alias ls='ls -F --color=auto'
  alias lsa='ls -aF --color=auto'
fi

alias ldrun='docker run --rm -v $(pwd):/local_volume'

function mkcd() {
  if [[ -d $1 ]]; then
    echo "$1 already exists!"
    cd $1
  else
    mkdir -p $1 && cd $1
  fi
}

function cdls() {
    cd $1 && ls
}

##### prompt #####
# use starship prompt
if type starship >/dev/null 2>&1; then
    export STARSHIP_CONFIG=$HOME/.starship.toml
    eval "$(starship init bash)"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

