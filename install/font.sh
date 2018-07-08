#!/bin/bash

wget https://github.com/masarakki/dotfiles/raw/master/fonts/Ricty-Regular.ttf
wget https://github.com/masarakki/dotfiles/raw/master/fonts/Ricty-Bold.ttf

if [ ! -e $HOME/.local/share/fonts ] ; then
    mkdir -p $HOME/.local/share/fonts/
fi

mv Ricty-* $HOME/.local/share/fonts/
