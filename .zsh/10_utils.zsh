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

# ostype returns the lowercase OS name
ostype() {
    echo ${(L):-$(uname)}
}

# os_detect export the PLATFORM variable as you see fit
os_detect() {
    export PLATFORM
    case "$(ostype)" in
        *'linux'*)  PLATFORM='linux'   ;;
        *'darwin'*) PLATFORM='osx'     ;;
        *'bsd'*)    PLATFORM='bsd'     ;;
        *)          PLATFORM='unknown' ;;
    esac
}

# set $PLATFORM
os_detect

# is_osx returns true if running OS is Macintosh
is_osx() {
    # os_detect
    if [[ $PLATFORM == "osx" ]]; then
        return 0
    else
        return 1
    fi
}
alias is_mac=is_osx

# is_linux returns true if running OS is GNU/Linux
is_linux() {
    # os_detect
    if [[ $PLATFORM == "linux" ]]; then
        return 0
    else
        return 1
    fi
}

# is_bsd returns true if running OS is FreeBSD
is_bsd() {
    # os_detect
    if [[ $PLATFORM == "bsd" ]]; then
        return 0
    else
        return 1
    fi
}

# get_os returns OS name of the platform that is running
get_os() {
    local os
    for os in osx linux bsd; do
        if is_$os; then
            echo $os
        fi
    done
}

fuzzy_search() {
    if has_cmd sk; then
        sk
    elif has_cmd peco; then
        peco
    else
        echo "Neither sk and peco are not installed!"
        exit 1
    fi
}