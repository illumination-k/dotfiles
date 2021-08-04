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

## peco
if not_has_cmd peco; then
    if has_cmd apt; then
        apt install -y peco
    elif has_cmd brew; then
        brew install peco
    else
        echo "apt or brew required to install peco"
    fi
fi