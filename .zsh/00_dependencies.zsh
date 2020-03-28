# detect platform has function or not
has_cmd() {
    if type $1 >/dev/null 2>&1; then
        return 0 
    else
        return 1
    fi
}

not_has_cmd() {
    if type $1 >/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

if not_has_cmd starship; then        
    if has_cmd curl; then
        curl -fsSL https://starship.rs/install.sh | bash --yes
    elif has_cmd wget; then
        wget https://starship.rs/install.sh 
        bash install.sh --yes
        rm -f install.sh
    else
        echo "curl or wget required to install starship"
    fi
fi

if not_has_cmd peco; then
    if has_cmd apt; then
        apt install -y peco
    elif has_cmd brew; then
        brew install peco
    else
        echo "apt or brew required to install peco"
    fi
fi