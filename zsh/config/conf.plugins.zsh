
# zsh-syntax-highlighting
is_exist_file $ZPLUGINSDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh && source $ZCONFDIR/plugins/conf.zsh-syntax-highlighting.zsh

# zsh-autosuggestions
# NOTE!!
# this plugin MUST be loaded after zsh-syntax-highlighting.zsh
is_exist_file $ZPLUGINSDIR/zsh-autosuggestions/zsh-autosuggestions.zsh && source $ZCONFDIR/plugins/conf.zsh-autosuggestions.zsh

# incr
# is_exist_file $ZPLUGINSDIR/incr/incr-0.2.zsh && source $ZCONFDIR/plugins/conf.incr.zsh

# auto-fu
# is_exist_file $ZPLUGINSDIR/auto-fu.zsh/auto-fu.zsh && source $ZCONFDIR/plugins/conf.auto-fu.zsh

# zaw
is_exist_file $ZPLUGINSDIR/zaw/zaw.zsh && source $ZCONFDIR/plugins/conf.zaw.zsh

