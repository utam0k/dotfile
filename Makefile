DOTFILES := $(shell pwd)
SHELL_RC = ${HOME}/.bashrc

all: setup zshrc pyenv python tmux nvim git
.PHONY: setup zshrc pyenv python tmux nvim git

setup:
	$(DOTFILES)/setup.sh

tmux:
	@if [ -e $(HOME)/.tmux.conf ]; then\
		mv $(HOME)/.tmux.conf $(HOME)/.tmux.conf.org; \
	fi
	ln -s $(DOTFILES)/tmux/tmux.conf $(HOME)/.tmux.conf

PYENV_ROOT = $(HOME)/.pyenv
PYTHON_VERSION = 3.11.2
PYENV = $(PYENV_ROOT)/bin/pyenv
PYENV_NVIM_BIN = $(PYENV_ROOT)/versions/nvim/bin
nvim:
	@if [ ! -e $(HOME)/.config ]; then\
		mkdir $(HOME)/.config; \
	fi
	@if [ -e $(HOME)/.config/nvim ]; then\
		echo "WARNING: $(HOME)/.config/nvim already exists."; \
	else \
		ln -s $(DOTFILES)/nvim $(HOME)/.config/nvim; \
	fi
	@if [ ! -e $(PYENV_ROOT)/versions/$(PYTHON_VERSION) ]; then\
		$(PYENV_ROOT)/bin/pyenv install $(PYTHON_VERSION); \
	fi
	@if [ ! -e $(PYENV_ROOT)/versions/nvim ]; then\
		$(PYENV) virtualenv $(PYTHON_VERSION) nvim; \
	fi
	$(PYENV_NVIM_BIN)/pip install --upgrade pip
	$(PYENV_NVIM_BIN)/pip install pynvim
	$(PYENV_NVIM_BIN)/pip install jedi flake8-import-order autopep8 black isort
	@echo "Neovim setup complete. Launch nvim to install plugins via lazy.nvim." 

pyenv:
	curl https://pyenv.run | bash
	echo Please install depenedencies to install Python following https://github.com/pyenv/pyenv/wiki

nvm:
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

arkade:
	curl -sLS https://get.arkade.dev | sudo sh

bashrc:
	@if [ -e $(HOME)/.bashrc ]; then\
		mv $(HOME)/.bashrc $(HOME)/.bashrc.org;\
	fi
	@if [ ! -e $(DOTFILES)/bash/conf.bash ]; then\
		cp $(DOTFILES)/bash/conf.bash.example $(DOTFILES)/bash/conf.bash;\
	fi
	ln -sf $(DOTFILES)/bash/bashrc $(HOME)/.bashrc

git:
	ln -fs $(DOTFILES)/git/gitignore ${HOME}/.gitignore
	ln -fs $(DOTFILES)/git/.gitconfig ${HOME}/.gitconfig

zshrc:
	cd zsh && ./build.sh
	ln -sf $(DOTFILES)/zsh/build/zshrc $(HOME)/.zshrc
	ln -sf $(DOTFILES)/zsh/build/zshrc.zwc $(HOME)/.zshrc.zwc
