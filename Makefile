DOTFILES := $(shell pwd)
SHELL_RC = ${HOME}/.bashrc
PYTHON_VERSION = 3.5.1

all: tmux nvim git pyenv python
.PHONY: tmux nvim git pyenv python
tmux:
	CONF = $(DOTFILES)/tmux/tmux.conf
	@if [ -f CONF ]; then\
		@echo "$(error %{CONF} is already exit.)";
	fi
	ln -s $(DOTFILES)/tmux/tmux.conf ${HOME}/.tmux.conf
nvim:
	CONF = $(DOTFILES)/nvim/init.vim
	@if [ -f CONF ]; then\
		@echo "$(error %{CONF} is already exit.)";
	fi
	cp nvim/init.vim.org nvim/init.vim
	ln -s $(DOTFILES)/nvim/ ${HOME}/.config/nvim/
pyenv:
	@if [ -f ${HOME}/.pyenv ]; then\
		@echo "$(error ${HOME}/.pyenv is already exit.)";
	fi
	export PYENV_ROOT="${HOME}/.pyenv" 
	@if [ -f ${PYENV_ROOT}/plugins/pyenv-virtualenv ]; then\
		@echo "$(error ${PYENV_ROOT}/plugins/pyenv-virtualenv is already exit.)";
	fi
	git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv
	echo 'export PYENV_ROOT="${HOME}/.pyenv"' >> ${SHELL_RC}
	echo 'export PATH="${PYENV_ROOT}/bin:${PATH}"' >> ${SHELL_RC}
	echo 'eval "$(pyenv init -)"' >>${SHELL_RC}
	git clone https://github.com/pyenv/pyenv-virtualenv.git $(PYENV_ROOT)/plugins/pyenv-virtualenv
	echo 'eval "$(pyenv virtualenv-init -)"' >> ${SHELL_RC}
python:
	pyenv install ${PYTHON_VERSION}
	pyenv virtualenv ${PYTHON_VERSION} neovim
	pip install neovim
	pyenv activate neovim
	pip install neovim
	sed -i "s@path to python@`pyenv which python`@g" nvim/init.vim 
	pyenv deactivate neovim
git:
	ln -fs $(DOTFILES)/git/gitignore ${HOME}/.gitignore
