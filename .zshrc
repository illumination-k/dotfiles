# first compile
if [ ! -f ~/.zshrc.zwc ]; then
    zcompile ~/.zshrc
fi

for f in `ls ~/.zsh/[0-9]*.zsh`; do 
    source $f; 
done

# compile if zshrc is updated
if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
   zcompile ~/.zshrc
fi
