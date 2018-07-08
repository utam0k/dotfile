#!/bin/bash

if uname -a | grep Ubuntu > /dev/null; then
	sudo apt-get install -y software-properties-common
	sudo add-apt-repository ppa:neovim-ppa/unstable
	sudo apt-get update
fi

sudo apt-get install -y neovim
