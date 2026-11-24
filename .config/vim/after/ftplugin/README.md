# Should I write a guard in one of my ftplugins?

No.

When your ftplugin will be sourced, a previous one:

    $VIMRUNTIME/ftplugin/{filetype}.vim

... will already have set the variable `b:did_ftplugin` (hit `gF`).

So,  if you  write a  guard,  it will  prevent  your ftplugin  from being  fully
sourced:

    " ✘
    if exists('b:did_ftplugin')
        finish
    endif
    let b:did_ftplugin = 1

# Should I create `b:did_ftplugin` in one of my ftplugins?

The purpose  of `b:did_ftplugin` is to  prevent any other filetype  plugins from
being sourced afterward.

So, if  your ftplugin  is in  an `after/` directory,  the answer  is: "NO, don't
create `b:did_ftplugin`".

Otherwise, "yes".

# Should I delete `b:did_ftplugin` or `b:undo_ftplugin`?

No.

Vim will do it automatically:

    $VIMRUNTIME/ftplugin.vim:27

# Can I define a function in one of my ftplugins?

No.

It should be in an `autoload/` directory.

You can either use `~/.vim/autoload/`, or the `autoload/` directory of an ad hoc
plugin (with a `ftplugin/`, and maybe `syntax/`, `indent/`, ...
directories).
