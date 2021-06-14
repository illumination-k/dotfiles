if [ -f ~/.profile ]; then
    source ~/.profile
fi

# load local profile
if [ -f ~/.local_profile ]; then
    source ~/.local_profile
fi

for f in `ls ~/.zsh/[0-9]*.zsh`; do 
    source $f;
done

# compile zshrc
if [ ! -f ~/.zshrc.zwc ] || [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
    zcompile ~/.zshrc
fi

# load repository profile
if [ -f $(git root)/.reporc ]; then
    source $(git root)/.reporc
fi
