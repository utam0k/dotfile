#!/bin/bash

if [ ! -e $HOME/.pyenv ] ; then
	git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
	git clone https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
fi
