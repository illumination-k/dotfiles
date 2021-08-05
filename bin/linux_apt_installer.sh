# install dependencies
## starship
if not_has_cmd starship; then  
    if has_cmd curl; then
        curl -fsSL https://starship.rs/install.sh | bash --yes
    elif has_cmd wget; then
        wget https://starship.rs/install.sh 
        bash install.sh --yes
        rm -f install.sh
    elif has_cmd cargo; then
        cargo install starship  
    else
        echo "cargo, curl or wget required to install starship"
    fi
fi

# gh
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# others
sudo apt update --fix-missing && \
    sudo apt install build-essential cmake zsh zplug tmux