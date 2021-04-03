# base

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

function gcmi() {
  issue_num="#$(gh issue list | peco | col 1)"

  if [ $issue_num != "#" ]; then
    git commit -m "$1 (${issue_num})"
  fi
}

function is_repo_exist() {
  repo_name="$(git config user.name)/$1"
  repos=($(gh repo list | col 0))
  if [[ $(printf '%s\n' "${repos[@]}" | grep -qx ${repo_name}; echo -n ${?} ) -eq 0 ]]; then
      return 0
  else
      return 1
  fi
}

function ghcr() {
  if [[ $(is_repo_exist $1) -eq 0 ]]; then
    echo -n "$1 is already exist\n"
    return 1
  fi

  gh repo create $*
  ghq get git@github.com:$(git config user.name)/$1.git

  repo_path=$(ghq list --full-path -e $1)
  cur_path=$(pwd)

  touch "${repo_path}/.gitignore"
  touch "${repo_path}/README.md"
  ce $repo_path
  git add .
  git commit -m "first commit"
  git checkout -b dev
  if has_cmd code; then
    code $repo_path
    cd $cur_path
  fi
}