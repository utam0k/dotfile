#!/bin/sh

export PATH=$PATH:$HOME/.go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

go get github.com/motemen/ghq
go get github.com/peco/peco/cmd/peco
