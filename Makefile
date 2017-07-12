DOTFILES := $(shell pwd)
SHELL_RC = ${HOME}/.bashrc
PYTHON_VERSION = 3.5.1

all: tmux nvim git python
.PHONY: tmux nvim git python
tmux:
	ln -fs $(DOTFILES)/tmux/tmux.conf ${HOME}/.tmux.conf
nvim:
	cp nvim/init.vim.org nvim/init.vim
	ln -fs $(DOTFILES)/nvim/ ${HOME}/.config/nvim/
python:
	git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv
	echo 'export PYENV_ROOT="${HOME}/.pyenv"' >> ${SHELL_RC}
	echo 'export PATH="${PYENV_ROOT}/bin:${PATH}"' >> ${SHELL_RC}
	echo 'eval "$(pyenv init -)"' >>${SHELL_RC}
	export PYENV_ROOT="${HOME}/.pyenv"
	export PATH="${PYENV_ROOT}/bin:${PATH}"
	eval "$(pyenv init -)"
	# . ${SHELL_RC}
	git clone https://github.com/pyenv/pyenv-virtualenv.git $(PYENV_ROOT)/plugins/pyenv-virtualenv
	echo 'eval "$(pyenv virtualenv-init -)"' >> ${SHELL_RC}
	eval "$(pyenv virtualenv-init -)"
	# . ${SHELL_RC}
	pyenv install ${PYTHON_VERSION}
	pyenv virtualenv ${PYTHON_VERSION} neovim
	# PYENV_VERSION=neovim pyenv exec pip neovim
	pip install neovim
	pyenv activate neovim
	pip install neovim
	sed -i "s@path to python@`pyenv which python`@g" nvim/init.vim 
	pyenv deactivate neovim
git:
	ln -fs $(DOTFILES)/git/gitignore ${HOME}/.gitignore
