vim9script

# Some `.nfo` files use special characters to make better-looking ASCII art.{{{
#
# Google “example nfo art”.
# Or visit: http://www.textfiles.com/piracy/NFO/
#
# Source:
# https://www.reddit.com/r/vim/comments/aj9ejv/view_nfo_files_with_vim/eetqozi/
#}}}
# Don't run  this unconditionally  (it might  break the  text in  some files).
# Look for  some unusual character(s) which  only appear when the  encoding is
# wrong.
if search('Û', 'cn') > 0
    # `:noautocmd`: to avoid `E218`.{{{
    #
    #     E218: autocommand nesting too deep
    #     Error detected while processing FileType Autocommands for "*":
    #     E218: autocommand nesting too deep
    #}}}
    # `:noswapfile`: to avoid `E325`.{{{
    #
    # If the  nfo file  is already  open in another  Vim instance,  you'll get
    # `E325`; that's  because our `SwapfileHandling` autocmd  is not triggered
    # (because of `:noautocmd`).  I don't want to be bothered by Vim asking me
    # whether I want to edit the file and how.
    #}}}
    noautocmd noswapfile edit ++encoding=cp437
endif
