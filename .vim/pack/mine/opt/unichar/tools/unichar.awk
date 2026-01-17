#!/usr/bin/awk -f

# Input: file downloaded from:
# ftp://ftp.unicode.org/Public/UNIDATA/UnicodeData.txt

# Output: Vimscript  code defining  the `unichar#Session#Dict()`  function which
# returns a dictionary mapping the code point of a character to its description

# Usage:
#
#     $ cd /path/to/unichar/tools/
#     $ ./unichar.awk <(curl -Ls ftp://ftp.unicode.org/Public/UNIDATA/UnicodeData.txt) >../autoload/unichar/Session.vim

# Most of the code is taken from:
# https://github.com/tpope/vim-characterize/blob/master/autoload/unicode.awk

BEGIN {
  FS = ";"
  while (getline < "header.txt" > 0)
    print $0
}

{
    code = $1
    name = $2
    alias = $11
    if (name == "<control>" && length(alias) != 0) {
        name = alias
    }
    printf "d[0x%s] = '%s'\n", $1, name
}

END {
  printf "\nexport def Dict(): dict<string>\n    return d\nenddef"
}
