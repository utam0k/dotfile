# ## emacs like なキーバインドに
# bindkey -e

reg-key "^H" backward-char
reg-key "^J" down-line-or-history
reg-key "^K" up-line-or-history
# reg-key "^L" forward-char

# 補完メニューのときの候補移動のキーバインド
reg-key "^H" backward-char       
reg-key "^J" down-line-or-history filterselect
reg-key "^K" up-line-or-history   filterselect
# reg-key "^L" forward-char        
# reg-key "^H" backward-char        menuselect
# reg-key "^J" down-line-or-history menuselect filterselect
# reg-key "^K" up-line-or-history   menuselect filterselect
# reg-key "^L" forward-char         menuselect

# Shift+Tab で逆順に補完候補を表示
reg-key "^[[Z" reverse-menu-complete

# # M-p,M-nでヒストリの前後を表示する(マッチしなくても通常のヒストリを表示?)
# reg-key "^[P" history-beginning-search-backward-end
# reg-key "^[N" history-beginning-search-forward-end


# ^ で上のディレクトリ
# zle -N cdup # cdup is define by conf.myfunction.zsh
reg-key '\^' cdup

local afu_available=0
local zaw_available=0

if is_exist_file $ZPLUGINSDIR/auto-fu/auto-fu.zsh; then
    afu_available=1
fi

if is_exist_file $ZPLUGINSDIR/zaw/zaw.zsh; then
    zaw_available=1
fi

if [ $zaw_available = 1 ]; then
    reg-key "n" down-line-or-history
    reg-key "p" up-line-or-history


    bindkey -r "^P"

    reg-key "^@"   zaw-cdr
    reg-key "^P^O" zaw-open-file
    reg-key "^P^A" zaw-applications
    reg-key "^R"   zaw-history
    zle -N zaw-git
    reg-key "^P^G" zaw-git
    reg-key "^P^B" zaw-git-branches
    reg-key "^P^P" zaw-process
    reg-key "^P^T" zaw-tmux
    zle -N zaw-screen
    reg-key "^P^S" zaw-screen
fi


# auto-fuで上書きされるためafuマップにバインド
if [ $afu_available = 1 ]; then
    reg-key "^H" backward-char        afu
    reg-key "^J" down-line-or-history afu
    reg-key "^K" up-line-or-history   afu
    reg-key "^L" forward-char         afu

    reg-key '\^' cdup                 afu

    if [ $zaw_available = 1 ]; then
        reg-key "^@"   zaw-cdr          afu
        reg-key "^P^O" zaw-open-file    afu
        reg-key "^P^A" zaw-applications afu
        reg-key "^R"   zaw-history      afu
        reg-key "^P^G" zaw-git          afu
        reg-key "^P^B" zaw-git-branches afu
        reg-key "^P^P" zaw-process      afu
        reg-key "^P^T" zaw-tmux         afu
        reg-key "^P^S" zaw-screen       afu
    fi
fi
