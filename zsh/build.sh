#!/bin/sh
BUILD_DIR=./build

if [ ! -d $BUILD_DIR/ ]; then
    mkdir "$BUILD_DIR"
fi
touch "$BUILD_DIR/zshrc"
echo > "$BUILD_DIR/zshrc"
rm -f "$HOME/.zcompdump"

find ./zshrc.d -maxdepth 1 -name "*.zsh" | sort | xargs cat >> "$BUILD_DIR/zshrc"
find ./zshrc.d/hooks -maxdepth 1 -name "*.zsh" | sort | xargs zsh >> $BUILD_DIR/zshrc

zsh -n "$BUILD_DIR/zshrc"
zsh -c "zcompile $BUILD_DIR/zshrc"
zsh -c "autoload -Uz compinit && compinit"
