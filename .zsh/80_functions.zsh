# utils functions
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

function col() {
    awk -v col=$1 '{print $col}'
}

# read files

function rcsv() {
  cat $1 | column -t -s $"," | less -S
}

function rzcsv() {
  zcat $1 | column -t -s $"," | less -S  
}

function rtable() {
  cat $1 | column -t | less -S
}

function rztable() {
  cat $1 | column -t | less -S
}

function rvcf() {
  zcat $1 | grep -v "#" | column -t | less -S
}

function skip() {
    n=$(($1 + 1))
    cut -d' ' -f$n-
}