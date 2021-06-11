DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard .??*)
EXCLUSIONS := .DS_Store .git .gitignore .github .bashrc
DIRECTORY  := .zsh
DOTFILES   := $(filter-out $(EXCLUSIONS) $(DIRECTORY), $(CANDIDATES))

deploy: ## Create symlink to home directory (NOT deploy bashrc)
	@echo "==> Start to deploy dotfiles to home directory"
	@echo "CAUTION: This command NOT deploy bashrc"
	@echo ""
	@$(foreach val, $(DOTFILES), ln -sfv $(abspath $(val)) $(HOME)/$(val);)
	@$(foreach val, $(DIRECTORY), ln -sfvn $(abspath $(val)) $(HOME)/$(val);)

bashrc: ## deploy bashrc
	@echo "==> deploy bashrc"
	@echo ""
	@ln -sfv $(abspath .bashrc) ${HOME}/.bashrc

list: ## Show dot files in this repoy
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val);)

exclude: ## Show ignore file when deploying
	@echo $(EXCLUSIONS)

clean: ## Remove the dot files and this repo
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)
	-rm -rf $(DOTPATH)

path: ## Show path in makefile
	@echo " DOTPATH    : $(DOTPATH)"
	@echo " CANDIDATES : $(CANDIDATES)"
	@echo " EXCLUSIONS : $(EXCLUSIONS)"
	@echo " DIRECTORY  : $(DIRECTORY)"
	@echo " DOTFILES   : $(DOTFILES)"

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'