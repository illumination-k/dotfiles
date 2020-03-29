# README

dotfiles of illumination-k

![terminal](doc/terminal.PNG)

## Usage

### dotfiles

```
curl -L https://raw.githubusercontent.com/illumination-k/dotfiles/master/etc/install.sh | bash
```

### install cargo dependencies

```
curl -L https://raw.githubuercontent.com/illumination-k/dotfiles/master/bin/cargo_installer.sh | bash
```


## Dependencies

```
curl -L https://raw.githubusercontent.com/illumination-k/dotfiles/master/bin/dependencies_installer.sh | bash
```

### SHELL
- zsh

### screen
- tmux

### PROMPT
- starship

### functions
- peco
- awk
- colum
- less
- zcat

### recommend

#### global
- docker
- code
- git
- exa
- rg
- fd
- bat

#### mac
- gls (if you do not have exa)
- brew

#### linux
- xsel

## ROADMAP

- [x] zcompile
- [x] add screenshot
- [ ] CI by github action
    - [ ] multi platform
    - [x] install.sh
    - [ ] cargo_installer.sh
    - [ ] dependencies_installer.sh
- [x] administrating by make
- [ ] update dependencies installer

## License
MIT