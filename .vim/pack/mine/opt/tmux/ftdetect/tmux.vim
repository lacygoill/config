vim9script

autocmd BufRead,BufNewFile {.,}tmux*.conf setfiletype tmux
autocmd BufRead,BufNewFile $HOME/.config/tmux/{*.conf,plugins_config/*,plugins/run} setfiletype tmux
