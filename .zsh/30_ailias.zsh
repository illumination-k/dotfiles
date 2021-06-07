# Common aliases

if has_cmd exa; then
    alias ls='exa -F'
    alias lsa='exa -aF'
    alias tree='exa -hTF --ignore-glob=".git"'
else 
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
      echo "unknown platform"
    fi
fi

# cd
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias h='cd ~'
alias dotf='cd ~/dotfiles'

# docker
alias d='docker'
alias ldrun='docker run --rm -it -v `pwd`:/local_volume'

# 複数ファイルのmv 例　zmv *.txt *.txt.bk
autoload -Uz zmv
alias zmv='noglob zmv -W'

# git
alias g='git'

# ghq
<<<<<<< HEAD
if has_cmd gqh; then
  alias gcd="cd $(ghq root)/$(ghq list | peco)"
  alias gcode="code $(ghq root)/$(ghq list | peco)"
fi
=======
alias gcd='cd $(ghq list -p | peco)'
alias gcode='code $(ghq list -p | peco)'

# gh

# ghq + gh
alias ghrw='gh repo view -w $(ghq list | peco)'
>>>>>>> 302df5a18c207216b1858c08057f6d22efb93498

# grep
if has_cmd rg; then
  alias grep='rg'
else
  alias grep='grep --color'
fi

# zshrc
if has_cmd code; then
  alias zshrc='code ~/.zshrc'
else
  alias zshrc='vi ~/.zshrc'
fi

alias reload="source ~/.zshrc"

# pbcopy (mac: pbcopy, WSL: clip.exe, Linux: xsel)
if [[ $PLATFORM == osx ]]; then
  alias c='pbcopy'
elif [[ $(uname -r | cut -f 3 -d "-") == "Microsoft" ]]; then
  alias c='clip.exe'
elif [[ $PLATFORM == linux ]]; then
  if has_cmd xsel; then
    alias c='xsel --clipboard --input'
  else
    echo "please install xsel to use c alias"
  fi
else
  echo "Unknown platform"
fi

alias getpwd='pwd | c'

# suffix
alias -s py=python
alias -s sh=bash
alias -s html='open'

function extract() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.tar.xz) tar Jxvf $1;;
    *.zip) unzip $1;;
    *.lzh) lha e $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.tar.Z) tar zxvf $1;;
    *.gz) gzip -d $1;;
    *.bz2) bzip2 -dc $1;;
    *.Z) uncompress $1;;
    *.tar) tar xvf $1;;
    *.arj) unarj $1;;
  esac
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract

# global alias
alias -g A='| awk'
alias -g C='| c'
alias -g W='| wc -w'
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g L='| less -R'
alias -g X='| xargs'