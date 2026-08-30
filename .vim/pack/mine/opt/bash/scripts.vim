vim9script

# This script is necessary for scripts which don't have any file extension.

if did_filetype()
    finish
endif

# Warning: Do  *not*   use  `\<`/`\>`;  it   might  break  the   detection  if
# `'iskeyword'` is somehow wrong.
if getline(1) =~ '^#!.*[ /]bash\%($\|\s\)'
        # for scripts like `~/.profile_local`
        .. '\|' .. '^#\s*shellcheck\s\+shell=bash$'
    setfiletype bash
endif
