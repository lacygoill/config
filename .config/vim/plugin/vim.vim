vim9script

# Don't let the default Vim ftplugin install mappings.{{{
#
#     $VIMRUNTIME/ftplugin/vim.vim
#
# ... defines  the buffer-local  mappings `["`, `]"`.  I don't  want them,
# because I use other global mappings (same keys), which are more powerful
# (support more filetypes).
#
# We could also set `no_plugin_maps`, but it would affect all default ftplugins.
# For the moment, I only want to disable mappings installed from the Vim ftplugin.
#}}}
# Warning: This can't  be set  from the  vimrc.  It  would be  too late  for a
# Vimscript file passed as an argument to vim on the shell's command-line.
g:no_vim_maps = 1
