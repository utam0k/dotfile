#!/bin/bash

if [ ! -e $HOME/.go ] ; then
	mkdir $HOME/.go
	wget -q https://storage.googleapis.com/golang/getgo/installer_linux
	chmod +x installer_linux
	./installer_linux
	rm installer_linux
fi
