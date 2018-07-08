#!/bin/sh

sudo apt install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

if uname -a | grep Ubuntu > /dev/null; then
	sudo add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) \
		stable"
fi

if uname -a | grep Debian > /dev/null; then
	sudo add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/debian \
		$(lsb_release -cs) \
		stable"""
fi

sudo apt-get update
sudo apt-get -y install docker-ce
