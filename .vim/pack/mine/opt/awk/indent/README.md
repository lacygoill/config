# Where does this script come from?

<http://www.vim.org/scripts/script.php?script_id=4372>

# What does it do?

It defines  `GetAwkIndent()` and  uses it  to set the  indentation of  the lines
filtered by the `=` operator.

It sets the options `'indentexpr'` and `'indentkeys'`:

    setlocal indentexpr=GetAwkIndent()
    setlocal indentkeys=0{,0},:,!^F,o,O,e

# Why don't you use the default indent plugin?

`$VIMRUNTIME/indent/awk.vim`  hasn't  been  updated  in a  long  time,  and  the
resulting indentation is often wrong.

# How to configure the script?

The configuration relies on a set of global variables documented at the top of the script.
