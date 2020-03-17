# Common aliases

os_detect

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

alias ldrun='docker run --rm -v `pwd`:/local_volume'

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