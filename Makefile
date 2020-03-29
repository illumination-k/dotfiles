DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard .??*)
EXCLUSIONS := .DS_Store .git .gitignore .github
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

deploy: ## Create symlink to home directory 
	@echo "==> Start to deploy dotfiles to home directory"
	@echo ""
	@$(foreach val, $(DOTFILES), ln -sfv $(abspath $(val)) $(HOME)/$(val);)

list: ## Show dot files in this repoy
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val);)

exclude: ## Show ignore file when deploying
	@echo $(EXCLUSIONS)

clean: ## Remove the dot files and this repo
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)
	-rm -rf $(DOTPATH)

path: ## Show path in makefile
	@echo $(DOTPATH)
	@echo $(CANDIDATES)
	@echo $(EXCLUSIONS)
	@echo $(DOTFILES)

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'