
source ~/.profile

for f in `ls ~/.zsh/[0-9]*.zsh`; do 
    source $f; 
done

# compile zshrc
if [ ! -f ~/.zshrc.zwc ] || [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
    zcompile ~/.zshrc
fi

if [ -f ~/.local_profile ]; then
    source ~/.local_profile
fi

