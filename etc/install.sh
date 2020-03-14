#!/bin/bash

DOTPATH=~/.dotfiles
GITHUB_URL="https://github.com/illumination-k/dotfiles.git"

# git が使えるなら git
if type git >/dev/null; then
    git clone --recursive "$GITHUB_URL" "$DOTPATH"

# 使えない場合は curl か wget を使用する
elif type curl >/dev/null || type wget >/dev/null; then
    tarball="https://github.com/illumination-k/dotfiles/archive/master.tar.gz"

    # どっちかでダウンロードして，tar に流す
    if type curl >/dev/null; then
        curl -L "$tarball"

    elif type wget >/dev/null; then
        wget -O - "$tarball"

    fi | tar zxv

    # 解凍したら，DOTPATH に置く
    mv -f dotfiles-master "$DOTPATH"

else
    die "curl or wget required"
fi

cd ~/.dotfiles
if [ $? -ne 0 ]; then
    die "not found: $DOTPATH"
fi

# 移動できたらリンクを実行する
for f in .??*
do
    [[ "$f" = ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".gitignore" ]] && continue

    ln -snfv "$DOTPATH/$f" "$HOME/$f"
done