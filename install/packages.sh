#!/bin/sh

sudo apt-get -y install\
	git \
	zsh\
	tmux\
	curl libcurl4-openssl-dev\
	openssh-server libssl-dev\

hash -r
