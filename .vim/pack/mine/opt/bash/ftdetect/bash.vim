vim9script

# For scripts which do have a file extension (`.sh` or `.bash`).
autocmd BufRead,BufNewFile *.sh,*.bash {
    # Warning: Do  *not*  use  `\<`/`\>`;  it might  break  the  detection  if
    # `'iskeyword'` is somehow wrong.
    if getline(1) =~ '^#!.*[ /]bash\%($\|\s\)'
        set filetype=bash
    endif
}

autocmd BufRead,BufNewFile ~/.bashrc set filetype=bash
