# install dependencies
## starship
if !(type "starship" > /dev/null 2>&1); then  
    if has_cmd curl; then
        curl -fsSL https://starship.rs/install.sh | bash --yes
    elif (type "wget" > /dev/null 2>&1); then
        wget https://starship.rs/install.sh 
        bash install.sh --yes
        rm -f install.sh
    elif (type "cargo" > /dev/null 2>&1); then
        cargo install starship  
    else
        echo "cargo, curl or wget required to install starship"
    fi
fi

# gh
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# others
sudo apt update --fix-missing && \
    sudo apt install build-essential gh cmake zsh zplug tmux