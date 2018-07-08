#!/bin/bash

function ConfirmGui() {
    echo "GUI? yes/no"
    read input
    if [ -z $input ] ; then
        echo "yes または no を入力して下さい."
        ConfirmGui
    elif [ $input = 'no' ] || [ $input = 'NO' ] || [ $input = 'n' ] ; then
        echo "Install without GUI"
    elif [ $input = 'yes' ] || [ $input = 'YES' ] || [ $input = 'y' ] ; then
        $basename/pkg/chrome.sh
        find install -name "*.sh" | sh
    fi
}

basename=`dirname $0`

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl git 

ConfirmGui
