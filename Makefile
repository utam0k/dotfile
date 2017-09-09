DOTFILES := $(shell pwd)
SHELL_RC = ${HOME}/.bashrc

all: bashrc pyenv python tmux nvim git
.PHONY: bashrc pyenv python tmux nvim git

tmux:
	@if [ -e $(HOME)/.tmux.conf ]; then\
		mv $(HOME)/.tmux.conf $(HOME)/.tmux.conf.org; \
	fi
	ln -s $(DOTFILES)/tmux/tmux.conf $(HOME)/.tmux.conf

PYENV_ROOT = $(HOME)/.pyenv
pyenv:
	git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv
	git clone https://github.com/pyenv/pyenv-virtualenv.git $(PYENV_ROOT)/plugins/pyenv-virtualenv

PYTHON_VERSION = 3.5.1
PYENV = $(PYENV_ROOT)/bin/pyenv
PYENV_NVIM_BIN = $(PYENV_ROOT)/versions/nvim/bin
nvim:
	@if [ -e $(HOME)/.config/nvim ]; then\
		echo "WARNIGN: $(HOME)/.config/nvim is already exist."; \
	else \
		ln -s $(DOTFILES)/nvim $(HOME)/.config/nvim; \
		cp nvim/init.vim.org nvim/init.vim; \
	fi
	@if [ ! -e $(PYENV_ROOT)/versions/$(PYTHON_VERSION) ]; then\
		$(PYENV_ROOT)/bin/pyenv install $(PYTHON_VERSION); \
	fi
	@if [ ! -e $(PYENV_ROOT)/versions/nvim ]; then\
		$(PYENV) virtualenv $(PYTHON_VERSION) nvim; \
	fi
	$(PYENV_NVIM_BIN)/pip install --upgrade pip
	$(PYENV_NVIM_BIN)/pip install neovim
	sed -i "s@path to python@$(PYENV_NVIM_BIN)/python@g" nvim/init.vim 

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
	@if [ -e $(HOME)/.zshrc ]; then\
		mv $(HOME)/.zshrc $(HOME)/.zshrc.org;\
	fi
	@if [ -e $(HOME)/.zshenv ]; then\
		mv $(HOME)/.zshenv $(HOME)/.zshenv.org;\
	fi
	ln -sf $(DOTFILES)/zsh/zshrc.zsh $(HOME)/.zshrc
	ln -sf $(DOTFILES)/zsh/zshenv.zsh $(HOME)/.zshenv
