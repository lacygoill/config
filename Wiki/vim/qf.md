# Configuration
## Which options control the shell program started by `:grep` and `:make`?

    'grepprg'
    'makeprg'

## Inside the values of these options, how to refer to the arguments passed to `:grep` and `:make` at run time?

Use the placeholder `$*`.

You can use several `$*` if needed.

##
## On which options do `:grep`, `:make`, `:cgetexpr` (& friends) rely to parse what they read?

`:grep` relies on `'grepformat'`.

All the other commands rely on `'errorformat'`.

##
## An option can be set to change how Vim redirects the output of a shell command.
### What's this option for a shell command executed by
#### `system()` or `:!`?

    'shellredir'

#### `:make` or `:grep`?

    'shellpipe'

##
### How to refer to the temporary file in the value assigned to these options?

Use the `%s` item.

If you don't use `%s`, it's appended automatically at the end.

###
### How to prevent 'shellpipe' from redirecting anything?

Set `'shellpipe'` to an empty string.

#### When is it useful to do that?

When  you want  `:make` to  write  to the  temporary  file itself,  and you  set
`'makeprg'` accordingly.

##
## How to change the location of the temporary file created to redirect the output of a shell command?

Configure:

    ┌─────────────┬────────────────────────┐
    │ option      │ affects these commands │
    ├─────────────┼────────────────────────┤
    │ 'makeef'    │ :make                  │
    │             │ :grep                  │
    ├─────────────┼────────────────────────┤
    │ 'errorfile' │ $ vim -q               │
    │             │                        │
    │             │ :cgetexpr (& friends)  │
    └─────────────┴────────────────────────┘

## What's the default value of 'errorfile'?

    errors.err

## What's the value of 'errorfile' if I populate a qfl by parsing the contents of a file?

The path to the latter.

Examples:

    $ grep -RHIins pat /etc | vim -q /dev/stdin
    :echo &ef
    /dev/stdin˜

    $ grep -RHIins pat /etc >/tmp/my_error_file ; vim -q /tmp/my_error_file
    :echo &ef
    /tmp/my_error_file˜

    $ vim -q <(shell cmd)
    :echo &ef
    /proc/self/fd/123˜

    $ vim
    :cd /tmp
    :cfile my_error_file
    :echo &ef
    my_error_file˜

##
# Properties of a qf entry
## What are the five properties of a qf entry related to its location?

   - bufnr
   - col
   - vcol
   - lnum
   - pattern

## What are its five other properties?

   - module
   - nr
   - text
   - type
   - valid

## What property of a qf entry can I set, but not get?

    'filename'

You can set it:

    :call setqflist([{'filename': $VIMRUNTIME.'/filetype.vim', 'valid': 1}])
    :cwindow

But not get it:

    :echo getqflist()[0]->keys()
    ['lnum', 'bufnr', 'col', 'pattern', 'valid', 'vcol', 'nr', 'type', 'module', 'text']˜
      no 'filename' key˜

##
## What's the 'module'  property of a qf entry?

The original purpose of the `'module'`  property is to replace the possible long
filepath of an entry with the much-shorter  name of a module, for which there is
an equivalence (i.e. only one filename matches this module name and vice versa).

As a result, the module name is used only for displaying purposes.
The filename is still used when jumping to the file.

   > For some languages the file paths can be really long.
   > For example in PureScript we often have locations as long as:
   >
   >     ./src/bower_components/purescript-free/src/Control/Comonad/Cofree.purs
   >
   > And it might get even longer when it expands to a fullpath.
   > This might  be helpful for  other languages where  there is a  clear mapping
   > between file system and **module name space** (Haskell, Python, NodeJs, etc).

<https://github.com/vim/vim/pull/1757#issuecomment-325200776>

## What's the 'pattern' property of a qf entry?

It's used to locate the position of the entry in the buffer.

## What's the 'type'    property of a qf entry?

It's a character standing for the type of the error (warning, information, ...).

For more info: `:help errorformat-multi-line`

##
# Properties of a qfl
## What are the nine properties of a qfl?

   - changedtick
   - context

   - id
   - nr
   - idx

   - items    (qfl entries)
   - size
   - title
   - winid    (id of the qf window if opened)


You can ask any of them via:

    :echo getqflist({'key': 0})

Example, to get the size of the current qfl:

    :echo getqflist({'size': 0})

## What are the three pseudo-properties of a qfl that I can ask, but not get?

   - all     (all of the properties of the qfl)
   - efm
   - lines

You can ask for `'all'`:

    :echo getqflist({'all': 0})

But you won't get the key `'all'` in the dictionary output.

## What are the five qfl properties I can ask, but not set?

   - all
   - changedtick
   - idx
   - size
   - winid

##
## What's the 'context' property of a qfl?

It lets you bind an arbitrary data (string, list, dictionary, ...) to a qfl:

Usage example:

    call setqflist([], 'a', {'id': 3, 'context': ['foo', 'bar', 'baz']})

This command binds the list `['foo', 'bar', 'baz']` to the qfl whose identifier is 3.

## What are the 'id' and 'idx' properties of a qfl?

`'id'` is a unique identifier assigned to the qfl.
Contrary to the position of a qfl in the stack (`'nr'`), which can change during
a Vim session, this identifier never changes.

`'idx'` is the position of the current entry in the qfl.

## What's the 'nr' property of a qf entry?   Of a qfl?

For  a  qf entry,  `'nr'`  is  its  error number  that  you  can  look up  in  a
documentation to get more info about the meaning of the error.

For a qfl, `'nr'` is its position in the stack.

##
## What's the main effect of giving the value `0` to a qfl property when using `getqflist()`?

The output  dictionary will  contain the  key matching  this property,  with the
right value for the selected qfl.

##
## If I describe a qfl via the nr `0`, which qfl does Vim select?

If you also describe  it via its `'id'` property, then Vim  selects the qfl with
this id.

Otherwise, it selects the current list.

## If I describe a qfl via the id `0`, which qfl does Vim select?

If you also describe it via its  `'nr'` property, then Vim selects the qfl whose
position in the stack is `'nr'`.

Otherwise, it selects the current list.

## If I describe a qfl via the nr `2` and the id `3`, which qfl does Vim select?

The qfl whose `'id'` is 3.

`'id'` has priority over `'nr'`.

## If I don't describe the qfl via 'id' nor 'nr', which qfl does Vim select?

The current one.

##
## If I set the two properties of a qf entry 'bufnr' and 'filename', how is its location determined?

`'bufnr'` has priority.
`'filename'` is ignored.

## If I set the three properties of a qf entry 'lnum', 'col', 'pattern', how is its location determined?

`'pattern'` has priority over `'lnum'` and `'col'`.

##
## How to refer to a qfl when I use `getqflist()` or `setqflist()`?

Via its `'nr'`  property and its position  in the stack, or  its `'id'` property
and its unique identifier.

If you need to target a qfl according to:

   - its contents, use its id (because it never changes)
   - its position in the stack, use its nr

## How to refer to the last qfl in the stack?

Assign the value `'$'` to its `'nr'` property.

##
## How to get the identifier of the third qfl in the stack?

    :echo getqflist({'nr': 3, 'id': 0}).id
                                    ^
                                    do NOT give `1`

                                    If you do, you probably won't get any valid info, because
                                    there's no qfl whose id and position in the stack are 1 and 3:

                                        :echo getqflist({'nr': 3, 'id': 1}).id
                                        {'nr': 0, 'id': 0} ✘˜

## How to get the position in the stack of the qfl whose identifier is `3`?

    :echo getqflist({'nr': 0, 'id': 3}).nr

Here, the purpose of `'nr': 0` is not to describe the qfl in which we're interested;
it's to force `getqflist()` to include the `'nr'` key in the output dictionary.

## How to get the entries of the first qfl in the stack?

    :echo getqflist({'nr': 1, 'items': 0})

## How to get the size of the third qfl in the stack?   The size of the stack?

Size of the third qfl:

    :echo getqflist({'nr': 3, 'size': 0}).size

Size of the qf stack:

    :echo getqflist({'nr': '$'}).nr

##
## How to check whether the qfl whose ID is 123 exists?

    if getqflist({'id': 123}).id == 123

## Why is it important for a plugin to be able to detect whether the qfl has been modified?

While  a plugin  is  asynchronously updating  a  qfl, the  user  might invoke  a
quickfix command, or another plugin could incorrectly update the quickfix list.

If that  happens, the plugin  should be able to  cancel the modification  it was
about to perform on the qfl.

IOW, the plugin needs a way to detect  that the qfl was modified, since the last
time it inspected the qfl.

## How can a plugin detect whether a qfl has been modified since the last time it inspected it?

It can inspect the `'changedtick'` property:

    " populate a qfl
    let last_change = getqflist({'changedtick': 0}).changedtick
    ...

    let new_change = getqflist({'changedtick': 0})changedtick
    if new_change != last_change
        return
    endif
    ...


Don't use `b:changedtick`;  the latter tracks the number of  times the qf buffer
has been modified.  The qf buffer is NOT the qfl (data structure).

##
# Populate a qfl from Vim
## What are the three commands similar to `:grep`?

    :grepadd

    :lgrep
    :lgrepadd

The commands beginning with `l` populate the loclist instead of the qfl.
The ones finishing  with `add` APPEND the matches to  the existing list, instead
of creating a new one.

## What are the pro/con(s) of `:vimgrep` compared to `:grep`?

Con:

It's slower than `:grep` because each searched file is loaded in memory.

Pro:

It can search any Vim regex.  Including multiline patterns, because newlines and
the encoding are automatically recognized.

## What are the three main characteristics defining the commands such as `:cgetexpr`?

This family of commands contains 18 members (2 x 3 x 3).

Their name can be broken down in 3 parts:

    A + B + C
    │   │   │
    │   │   └ end
    │   └ middle
    └ beginning

They can:

    ┌──────────────────────┬─────────┐
    │ populate the qfl     │ A = 'c' │
    ├──────────────────────┼─────────┤
    │ populate the loclist │ A = 'l' │
    └──────────────────────┴─────────┘

    ┌──────────────────────────────────────┬───────────┐
    │ JUMP to the first entry              │ B = ''    │
    ├──────────────────────────────────────┼───────────┤
    │ NOT jump and REPLACE the list        │ B = 'get' │
    ├──────────────────────────────────────┼───────────┤
    │ NOT jump and ADD entries to the list │ B = 'add' │
    └──────────────────────────────────────┴───────────┘

    ┌───────────────────────┬──────────────┐
    │ read a Vim expression │ C = 'expr'   │
    ├───────────────────────┼──────────────┤
    │ read a file           │ C = 'file'   │
    ├───────────────────────┼──────────────┤
    │ read a buffer         │ C = 'buffer' │
    └───────────────────────┴──────────────┘

## What type of argument does each of these commands expect?

It depends on the middle part of its name.

If it's:

   - 'expr'    the command expects an expression
   - 'file'    "                   a filename
   - 'buffer'  "                   a buffer number

##
## What are the seven steps occurring when I execute `:make`?

1. Vim executes the autocmds listening to `QuickFixCmdPre`

2. Vim writes the modified buffers (`&modified` = 1)

3. Vim creates a temporary error file

4. Vim passes to the shell  `'shell'` the program `'makeprg'` + the optional
arguments passed to `:make`.

The output of `'makeprg'` is redirected into the error file via `'shellpipe'`.

5. Vim parses the error file via 'efm' to populate the qfl.

       :help error-file-format

6. Vim executes the autocmds listening to `QuickFixCmdPost`

7. Vim removes the error file

## What command is similar to `:make`?

    :lmake

##
## How to look for `pat` in the buffer 1-10?

    :cexpr []
             see # Issues
             v-------v
    :silent! noautocmd 1,10 bufdo [l]vimgrepadd /pat/gj %
           ^
           if the pattern is absent from a buffer, it will raise an error,
           which could prevent `:bufdo` from finishing visiting the next buffers
           inside the range


To search in all the buffers, remove the range in front of `:bufdo`.


Also, our  custom commands `:{C|L}GrepBuffer`  implement this snippet in  a more
complete way.

## How to look for `pat` in ALL (any depth) `.c` and `.h` files of `:pwd`?

                      don't jump to the first entry
                      v
    :[l]vimgrep /pat/gj **/*.[ch]
                     ^
                     if there're several occurrences on the same line, get all of them

## How to look for `pat` in the subdirectories ending with `.d/` inside `/etc/apt`?

                               no need to escape the dot;
                               in a FILE pattern:

                                   - dot is not interpreted as a meta character
                                   - `?` matches any single character
                               v
    :[l]vimgrep /pat/gj /etc/**.d


`:[l]vimgrep` expects filenames, not directory names.
And yet, here, `/etc/**.d` matches directories, not files.
This probably  shows that, when necessary,  Vim automatically appends `/*`  to a
pattern:

    :[l]vimgrep /pat/gj /etc/**.d

                ⇔

    :[l]vimgrep /pat/gj /etc/**.d/*
                                 ^^

## How to look for `pat` in all the files of `:pwd`, changed in the last hour?

                        backtick expansion:
                        expanded into the output of `$ find ...`
                        v------------------------v
    :[l]vimgrep /pat/gj `find . -cmin -60 -type f`
                              ^
                              matches the output of `:pwd`, NOT `$PWD`

Whenever you  want to look  for a pattern  in a set of  files which can  only be
defined by a shell command, use a backtick expansion.

##
## How to parse all the lines containing `pat` in the current buffer to populate the qfl?

    :cexpr []


     see # Issues
     v
    :noautocmd global/pat/ :. caddbuffer


It should work if the lines can be parsed by at least one format in `'efm'`.

But if they don't, you'll need to transform them so that they can be parsed.
For example, assuming your lines look like this:

    /path/to/some/file@line number@message

And you want them to be parsable by the format `'%f:%l:%m'`, you could try:

    :noautocmd g/pat/caddexpr getline('.')->tr('@', ':')

## How to parse the output of a shell command and get a qfl, without modifying the qf stack?

    echo getqflist({'lines': systemlist('# shell cmd'), 'efm': '{format}'})

When  you pass  the optional  dictionary `{'lines':  ...}` to  `getqflist()`, it
returns a dictionary with a single `'items'` key.
The value associated to this key is a list of sub-dictionaries.

Each of them contains some information about an entry in the qfl:

   - line
   - column
   - text
   - ...

For Vim to  parse the output of  the shell command, it needs  to create unlisted
buffers to read the files where there's at least one entry.
Therefore, every entry in the qfl has a `'bufnr'` key.

In addition  to `'lines'`, you  might include an  `'efm'` key in  the dictionary
passed to `getqflist()`, to  let Vim know how to parse  the output.  Without the
`'efm'` key, Vim will use the `'efm'` option.

##
## How to populate the qfl with a grep-like shell command different than `&grepprg`?

    :silent cgetexpr system('grep-like cmd')

## How to populate a valid qfl with `$ find /etc -name '*.conf'` without altering the 'errorformat' option?

    silent let qfl = getqflist({'lines': systemlist('find /etc/ -name "*.conf"'), 'efm': '%f'})
    call get(qfl, 'items', [])->setqflist()
    cwindow

---

TODO: Document that there exists a simpler command to get the same results:

    :vimgrep /\%^/ /etc/**/*.conf

Although, you might not get exactly the same results:

   - some entries might be duplicate (probably because of symlinks)
   - some entries might be missing (probably because Vim can't read a file owned by another user, like root)

## How to populate a qfl with a location which has never been visited (i.e. absent from all buffers)?

Use the `'filename'` property:

    :silent call system('touch /tmp/new_file')
    :call setqflist([{'filename': '/tmp/new_file', 'valid': 1}])
    :cwindow

    :silent call system('trash-put /tmp/new_file')

## How to populate the qfl whose ID is `123` with the output of a shell command?   (in one line)

    silent call setqflist([], 'r', {'id': 123, 'lines': systemlist('your shell cmd')})

##
## I have a long-to-type set of files.  How to effectively and *consecutively* look for different patterns in it?

Populate the arglist with the set of files (`:args`).
Then, use the special characters `##` to refer to it:

    :vimgrep /pat1/gj ##
    :vimgrep /pat2/gj ##
    ...

`##` lets you abstract a complex set of files, and focus on what varies/matters:
the pattern.

## What rarely-mentioned commands are necessary to look for several patterns SIMULTANEOUSLY in a codebase?

`:colder` and `:cnewer`.


For example, suppose you want to refactor `FuncA()`.
You  begin by  populating the  qfl  with all  the locations  where `FuncA()`  is
defined/called:

    :vimgrep /FuncA/gj *.c

But before changing the implementation, you want to rename `FuncA()`:

    :cdo s/FuncA/NewNameA/e | update

In the process,  you've noticed that `FuncA()` called `FuncB()`,  whose name was
derived from `FuncA`.
It has become irrelevant, so now you also need to rename `FuncB()`:

    :vimgrep /FuncB/gj *.c
    :cdo s/FuncB/NewNameB/e | update

The process repeats itself.

After having  renamed every function,  you can go back  to the original  qfl via
`:colder [count]`.
And at any  moment, in case of an  error, you could have moved in  the stack via
`:colder` and `:cnewer`.


The qf stack lets you bind to each pattern a separate qfl.

##
## How to create a new qfl at the end of the stack?

    silent call setqflist([], ' ', {'nr' : '$', 'lines' : systemlist('grep -RHIins pat *')})

##
# Populate a qfl from the shell
## How to parse the output of the last shell command during Vim startup?

    $ vim -q <(!!)

Don't use this:

    $ !! | vim --not-a-term -q /dev/stdin

It works, but it might leave the terminal in an unexpected state:
on my machine, after using this command,  I can't close the terminal with `C-d`;
I need to execute `exit`.

## How to look for all the lines matching `pat` in $PWD, and send them to a running Vim server?

                              don't use the options `-RHIins`;
                              you don't know which program is started by `:grep`;
                              the options should be passed when setting 'grepprg'
                              v
    $ vim --remote-send ':grep pat *<cr><cr>' --servername {name of the vim server}
                                         ^
                                         bypass “press Enter” prompt

Or:

    $ nv -q 'grep -RHIins pat *'

##
# Limit the population of a qfl
## How to empty the qfl? (via a command and via a function)

This command *creates* a new empty qfl in the stack:

    :cexpr []

These commands *replace* the current qfl with an empty list:

    :call setqflist([], 'r')
    :call setloclist(0, [], 'r')

## How to make `:cgetbuffer` read only the lines 12 to 34 of the buffer 56?

Any command whose final part of the name is `buffer` accepts a range.
So, you can execute:

    :12,34 cgetbuffer 56

## How to stop `:vimgrep` from populating the qfl after having found 123 matches in a file?

    :123 vimgrep pat file

This syntax  is particularly  useful to  check whether a  file contains  a given
pattern, without looking for all the matches:

    :1 vimgrep pat file

##
# Open the qf window
## How to open the qf window with a height of 15 lines?

    :copen 15
    :cwindow 15

## Does `:[l]vimgrep` open the qf window?

No.

But, it emits `QuickFixCmdPost`.
So,  you can  install  an autocmd  listening  to  this event,  and  Vim will  to
automatically open the qf window after a `:vimgrep` command.

## What commands are DIRECTLY responsible for the opening of the qf window?

    :copen
    :cwindow

If the  qf window  is opened on  your system after  a `:vimgrep`  or `:helpgrep`
command, it's only because of an autocmd/plugin.

## In which state (open/closed) is the qf window after `:copen`?   After `:cwindow`?

After `:copen`, the qf window is open, no matter what.

After `:cwindow`,  the qf window is  open if, and  only if, the qfl  contains at
least one entry whose `'valid'` key has the value 1.

## When does `QuickFixCmdPost` occur?

After a command (!= function) populating the qfl or loclist is executed.
Whether it finds something doesn't matter.

`FileType qf` is fired afterward.

## Do `setqflist()` and `setloclist()` fire `QuickFixCmdPost`?   Why?

No.

Theory:

These are functions, not commands.

Functions are low-level tools for plugins developers (or advanced users).
As  such, they  must do  one thing  and  one thing  only, to  let the  developer
implement the exact behavior they want.

OTOH, built-in commands  (`:make`, `:grep`, ...) are for users,  who most of the
time want the qf window to be opened automatically.  To do so, they need to have
an event to listen to, and install an autocmd.

IOW, if  `:make` didn't fire  `QuickFixCmdPost`, the user  would have no  way to
make it open the qf window  automatically, aside from creating a custom wrapper,
and an abbreviation (`:make` → `:Make`).

## Do `setqflist()` and `setloclist()` open the qf window?   Do they focus the qf window?

No and no.

However, assuming  you have  a custom  autocmd which handles  how the  qf window
should be opened, you can rely on the latter via `:doautocmd`:

    " autocmd opening the qf window
    autocmd QuickFixCmdPost  *  ...
                                ^^^
                                custom command/function invoking:

                                        :c{window|open} [height]

                                it can get the name of the command populating the qfl via:

                                        expand('<amatch>')


    " populate the qfl by invoking `setqflist()`
    call setqflist(...)
                   ^^^
                   for a simple test, use:    [ {'valid': 1} ]


    " rely on the previous autocmd to handle how the qf window should be opened
    doautocmd <nomodeline> QuickFixCmdPost grep
                                           ^--^
                                           if your autocmd reacts differently
                                           depending on whether the qf window displays a location list,
                                           or depending on the name of the command which populated the qfl,
                                           choose the name wisely

## How to automate the execution of a command after a command populating the qfl (!= loclist) has been executed?

                     all the commands populating a loclist begin with an `l`
                     so all the ones populating a qfl begin with `[^l]`
                     v--v
    QuickFixCmdPost  [^l]*  Your_command
                         ^
                         a star is not equivalent to the quantifier `*` in a file pattern
                         it's equivalent to the regex `.*`

                         IOW:

                              [^l]*         ⇔  [^l].*
                              file pattern     regex

You can't use `c*` because some commands populating the qfl don't begin with `c`:

   - `make`
   - `vimgrep[add]`
   - `grep[add]`

##
# Navigate in a qfl
## How to display the qf stack?

    :chistory

The current one is prefixed with a `>`.

## How to navigate in the qf stack?

    :colder
    :cnewer

## How to jump back to the current entry in the loclist?

    :cc
    :ll

Useful after navigating in the file or other files.

## How to jump to the entry 123?

    :cc 123
    :ll 123

## What are the other six custom motions we can perform in a qfl?

    ┌─────────────────────────────────┬────────────────┬──────────────┐
    │             purpose             │ custom command │ Ex command   │
    ├─────────────────────────────────┼────────────────┼──────────────┤
    │ previous entry                  │ [q             │ cprevious    │
    │                                 │ [l             │ lprevious    │
    ├─────────────────────────────────┼────────────────┼──────────────┤
    │ next entry                      │ ]q             │ cnext        │
    │                                 │ ]l             │ lnext        │
    ├─────────────────────────────────┼────────────────┼──────────────┤
    │ first entry                     │ [Q             │ cfirst       │
    │                                 │ [L             │ lfirst       │
    ├─────────────────────────────────┼────────────────┼──────────────┤
    │ last entry                      │ ]Q             │ clast        │
    │                                 │ ]L             │ llast        │
    ├─────────────────────────────────┼────────────────┼──────────────┤
    │ last entry in the previous file │ [ C-q          │ cpfile       │
    │                                 │ [ C-l          │ lpfile       │
    ├─────────────────────────────────┼────────────────┼──────────────┤
    │ first entry in the next file    │ ] C-q          │ cnfile       │
    │                                 │ ] C-l          │ lnfile       │
    └─────────────────────────────────┴────────────────┴──────────────┘

## What are the two motions we can perform in the qf stack?

    ┌──────────┬────────────────┬────────────┐
    │ purpose  │ custom command │ Ex command │
    ├──────────┼────────────────┼────────────┤
    │ previous │ <q             │ colder     │
    │          │ <l             │ lolder     │
    ├──────────┼────────────────┼────────────┤
    │ next     │ >q             │ cnewer     │
    │          │ >l             │ lnewer     │
    └──────────┴────────────────┴────────────┘

## How to prevent Vim from jumping to the first entry, when I execute a command to populate the qfl?

It depends on the command you use.

----------

If the name of the command follows this scheme:

    :{c|l}[add|get]{buffer|expr|file}

Use `get` or `add` in the middle of the name of the command.

Example:

    :cgetfile
      ^-^

----------

If the command is `:[l]vimgrep[add]`, use the `j` flag.

Example:

    :vimgrep /pat/gj files
                   ^

----------

If the command is `:[l]grep[add]` or `:[l]make`, use a bang.

Example:

    :make!
         ^

##
## How to jump to the next entry relative to the current cursor position?

    :cafter
    :lafter

### Same thing but ignoring the entries on the current line?

    :cbelow
    :lbelow

---

These commands only consider the first entry on a line.
So, if you execute sth like `:3cbelow`,  Vim doesn't jump to the 3rd entry after
the cursor, but to the *first* entry  on the third *line* after the cursor where
an entry can be found.

### What happens when I run these commands while I'm on the last entry of the buffer?

`E553` is raised.
They don't jump to the next entry in the quickfix list.
They are limited to the current buffer.

##
## How to jump to the previous entry relative to the current cursor position?

    :cbefore
    :lbefore

### Same thing but ignoring the entries on the current line?

    :cabove
    :labove

##
# Operate on the entries of a qfl
## What are the four actions I can pass to `setqflist()` in its second argument?

    ┌────────┬─────────────────────────────┐
    │ 'a'    │ append the items to the qfl │
    ├────────┼─────────────────────────────┤
    │ 'f'    │ free the qf stack           │
    ├────────┼─────────────────────────────┤
    │ 'r'    │ replace the qfl             │
    ├────────┼─────────────────────────────┤
    │ ' '/'' │ create a new qfl            │
    └────────┴─────────────────────────────┘

## How to modify the qfl (data structure) by directly editing the qf buffer?

You can't ONLY edit the qf buffer and be done with it.

There would be a discrepancy between the qf buffer and the qfl.
As a result, clicking on an entry might have an unexpected result.

You  need to  also execute  `:cgetbuffer`, AND  have a  properly set  `'efm'` by
adding something like this in `~/.vim/after/ftplugin/qf.vim`:

    let &l:efm = '%f%*\s\|%l col %c%*\s\|%m'


From there, here's the procedure you need to follow:

   - make the qf buffer temporarily modifiable

   - edit the buffer

   - update the qfl using `:cgetbuffer`

   - make the qf buffer unmodifiable, and unmodified

Relevant help section:

    :help ^w_<cr>

## How to replace all occurrences of a pattern in all the files of the qfl?

                      avoid E486
                      v
    :cfdo %s/pat/rep/ge | update
                        ^------^
                        avoid E37 and E89 if 'hidden' is reset

## How to delete all the lines containing an entry in the qfl, except the first ten?

    :11,$ cdo delete _ | update

## How to yank the first entry of: the file 1 in the qfl + ... +  the file 10 in the qfl?

    qaq
    :1,10 cfdo y A

This will yank in the register `a`, the line of the first entry in:

   - the first  file of the qfl
   - the second file of the qfl
   ...
   - the tenth  file in the qfl

This works because `:cfdo`  moves the cursor on the first entry  of each file in
the qfl.

## I want to repeat a command for each entry in the qfl.  How to make it more reliable?

If you execute a command which modifies the buffer, update it afterward:

    " ✘
    :silent! noautocmd cdo delete _

    " ✔
    :silent! noautocmd cdo delete _ | update
                                    ^------^

---

If you execute a substitution command, use the `e` flag:

    " ✘
    :noautocmd cdo s/pat/rep/ | update

    " ✔
    :noautocmd cdo s/pat/rep/e | update
                             ^

---

If you execute a  command which *can* change the focused  window, prefix it with
`:noautocmd`:

    " ✘
    :silent!           bufdo vimgrepadd /pat/gj %

    " ✔
    :silent! noautocmd bufdo vimgrepadd /pat/gj %
             ^-------^

---

If you  execute `:{arg|buf|c|cf|l|lf|tab|win}do`, and you  suspect the following
command might raise an error, prefix the whole command with `silent!`:

    " ✘
    :        noautocmd argdo :% caddbuffer

    " ✔
    :silent! noautocmd argdo :% caddbuffer
     ^-----^

## How does `:cdo` interpret a range?   What about `:cfdo`?   `:cgetbuffer`?  `:bufdo`?

    ┌─────────────┬─────────────────────────────────────────────┐
    │ :cdo        │ positions of the ENTRIES in the qfl         │
    ├─────────────┼─────────────────────────────────────────────┤
    │ :cfdo       │ positions of the FILES in the qfl           │
    ├─────────────┼─────────────────────────────────────────────┤
    │ :cgetbuffer │ addresses of the LINES in the buffer        │
    ├─────────────┼─────────────────────────────────────────────┤
    │ :bufdo      │ positions of the BUFFERS in the buffer list │
    └─────────────┴─────────────────────────────────────────────┘

## How to shorten the filepath displayed in the qf window to the filename?

Use the `'module'` and `'items'` key:

    call setqflist([], 'r',
        \ {'items': getqflist()->map({_, v -> extend(v, {'module': bufname(v.bufnr)->fnamemodify(':t')})})})

`'module'` lets you change the text displayed in the filename column.

`'items'` lets you update the items in the qfl without affecting its title, in a
single invocation of `setqflist()`.
Without `'items'`, you would need two:

    let new_qfl = getqflist()->map({_, v -> extend(v, {'module': bufname(v.bufnr)->fnamemodify(':t')})
    call setqflist(new_qfl, 'r')
    call setqflist([], 'a', {'title': getqflist({'title': 0})->get('title', ':setqflist()')})

Because:

   - `call setqflist(list, 'r')` replaces the items in the qfl, but ALSO
     its title

   - `setqflist()` ignores  the first  argument, when  you provide  the
     third optional one; so you can't replace both the items and the title
     of a qfl at the same time, with:

           call setqflist([...], 'r', {'title': '...'})

##
# Miscellaneous
## When I use `:lhelpgrep` or `:helpgrep`, is the search case-sensitive or insensitive?

Sensitive, no matter how `'ignorecase'` is set.

If you want it to be insensitive, add the atom `\c`:

    :lhelpgrep \cfoo.\{,12}bar
               ^^

In this example, we search for `foo` + 0 up to 12 characters + `bar` in the help
files.

## How to set the title of a qfl?

If a window displaying the qfl is opened, and it's currently focused:

    let w:quickfix_title = 'your title'

Otherwise:

    call setqflist(    [], 'a', {'title': 'your title'})
    call setloclist(0, [], 'a', {'title': 'your title'})

The second solution is more reliable:

   - you don't need to be in the qf window
   - it persists even after closing and re-opening the qf window

## How to get all the info about all the opened qf windows in the current Vim session?

For the qf windows:

    :echo getwininfo()->filter({_, v -> v.quickfix && !v.loclist})

For the location windows:

    :echo getwininfo()->filter({_, v -> v.quickfix &&  v.loclist})

## How to programmatically detect whether Vim was started with the `-q` argument?

If Vim was started with `-q`, `'ef'` will contain the path to the file which was
parsed to populate the qfl, instead of the default value `errors.err`.

    if &errorformat == 'errors.err'
        # Vim was started WITHOUT `-q`
    else
        # Vim was started WITH `-q`
    endif

##
## Why is the output of `getqflist()` not reliable to be saved, then used later to restore the qfl?

If you wipe the buffer before restoring the qfl, it will give an error.

    $ echo 'pat' >/tmp/file

    :vimgrep /pat/j /tmp/file
    :let qfl = getqflist()
    :bwipeout /tmp/file

    :call setqflist(qfl)
    E92: Buffer 123 not found˜

## How to reliably save then later restore the qfl?

For each entry, add the `'filename'` key, and then remove the `'bufnr'` key:

    let qfl = getqflist()
        \ ->map({_, v -> extend(v, {
        \ 'filename': remove(v, 'bufnr')
        \     ->bufname()
        \     ->fnamemodify(':p')
        \ })})

##
## When does a newly created window have a location list?

When the window from which it was created had already one.

When you  open a window, in  the current tab page  or in a new  one, it inherits
every  window-local settings  of the  window from  which you  created it.   This
includes the location list.

### How to empty it?

Maybe with something like:

    augroup prevent_location_list_inheritance
        autocmd!
        autocmd WinNew * silent! call setloclist(0, [], 'f')
    augroup END

---

BTW, this wouldn't empty the loclist of the location window.

Theory:

From `:help setloclist()`:

    For a location list window, the *displayed* location list is modified.
          ^------------------^
          != regular window

When `WinNew` is fired, there's probably *no displayed* location list yet.
So, the autocmd fails to mutate the location list.

Confirmed by the fact that if we slightly delay the autocmd, it *does* empty the
loclist:

    autocmd WinNew * call timer_start(0, {-> setloclist(0, [], 'r')})

#### Why is it a bad idea?

When you press `C-w CR` in a qf window, Vim creates a new window with an unnamed
buffer,  then it  tries to  open the  entry in  the location  list on  which you
pressed the keys.

If you have an  autocmd emptying the location list, there  won't be anything for
Vim to display in the new window.
This will raise the error:

                                                replace current loclist
                                                v
   - E42:  No Errors         , if you gave the 'r' action to `setloclist()`
   - E776: No location list  , "               'f' "
                                                ^
                                                delete all loclists

##
# Issues
## Why does  `:helpgrep \~$`  fail?

From `:help :helpgrep`:

   > The pattern does not support line breaks, it must match within one line.

---

Although, for some reason, replacing `$` with `\n` fixes the issue:

    " ✔
    :helpgrep \~\n

But the pattern breaks the command again if you add something after the newline:

    " ✘
    :helpgrep \~\n\_.

## Why does  `$ vim -q $(cmd)`  fail?

`-q` expects a filename containing valid errors.
Not directly the errors themselves.

## Why does  `:vimgrep /pat/gj /etc/apt/**/`  fail?

Usually, Vim would complete such a file pattern by adding `/*` at the end:

    :vimgrep /pat/gj /etc/apt/**

                ⇔

    :vimgrep /pat/gj /etc/apt/**/*

Not here, because of the ending slash.

Maybe  an  ending slash  indicates  to  Vim that  you're  really  looking for  a
directory, not files.

## Why does  `:vimgrep /pat/gj /etc/*.conf | cdo s//rep/e`  fail?

The pattern  used in  a `:[l]vimgrep[add]`  command is NOT  saved in  the search
register.

So, you need to write the pattern explicitly in the substitution:

    :vimgrep /pat/gj /etc/*.conf | cdo s/pat/rep/e | update
                                         ^^^

## Why does  `:bufdo grepadd pat %`  sometimes fail?

`:grepadd` jumps to the first error, which is forbidden by `:bufdo`.

Add a bang after `:grepadd`.

    :bufdo grepadd! pat %
                  ^

Also, you should probably use `:silent!` so that `:bufdo` processes all buffers,
even if an error occurs in one of them.

## Why do commands populating the qfl progressively (:vimgrepadd, :caddexpr, ...) sometimes fail?

If you have an autocmd opening the qf window, it could interfere in the process.

The solution is to prefix your qf commands with the `:noautocmd` modifier.


Example 1:

    " ✘
    " This will open a new split for every buffer.

    :silent!           bufdo vimgrepadd /pat/gj %

    " ✔

    :silent! noautocmd bufdo vimgrepadd /pat/gj %
             ^-------^


Example 2:

    " ✘
    " This will probably capture only the first line where `pat` matches,
    " because when the qf window is opened, the focus is changed.

    :          global/pat/caddexpr getline('.')->tr('@', ':')

    " ✔

    :noautocmd global/pat/caddexpr getline('.')->tr('@', ':')
     ^-------^

### ?

You've just recommended to use `:noautocmd`.
However, `:noautocmd` is problematic for other reasons.

First,  it suppresses  `Syntax`,  which  in turn  prevents  the  files in  which
`:lvimgrep` looks for from being highlighted:

    $ vim -Nu NONE --cmd 'syntax on' +'noautocmd lvimgrep /autocmd/ $VIMRUNTIME/filetype.vim'

Second, it might prevent `E325` from  being visible, which is confusing, because
it looks like Vim is blocked.
The issue is actually triggered by a combination of `:silent` and `try/catch`.
But you can work  around it with an autocmd listening  to `SwapExists`, which we
currently have in our vimrc.  Unfortunately, `:noautocmd` suppresses it.

See this MRE:

    # in a terminal
    $ vim -Nu NONE --cmd 'set directory=$HOME/.local/share/vim/swap//' /tmp/file

    # in another terminal
    $ vim -Nu NONE -S <(tee <<'EOF'
        vim9script
        set directory=$HOME/.local/share/vim/swap//
        autocmd SwapExists * v:swapchoice = 'o'
        def Func()
            try
                 silent noautocmd lvimgrep /x/ /tmp/file
                 #      ^-------^
                 #       ✘
            catch /E325/
                echomsg 'E325 was caught'
            endtry
        enddef
        Func()
    EOF
    )

For more info, see `exception.md /unblock`.

So, what should we do in the general case?
We could keep  using `:noautocmd`, but avoid `:silent`; however  that would only
fix the second issue; not the one with the lost syntax highlighting.

I   think   the   best   solution  is   temporarily   set   `'eventignore'`   to
`QuickFixCmdPost`, or maybe `QuickFixCmdPre,QuickFixCmdPost`.   But that's a bit
cumbersome, because you need  to save the option, then set  it, then restore it;
all of this requires a try/catch with  a `finally` clause in case something goes
wrong.  How about asking for a new modifier?  `:noquickfixcmd`?

##
##
#
# TODO
## ?

Remember that we use `:doautocmd QuickFixCmdPost` to open the quickfix window in
our plugins?   What pattern  should we use?  `[cl]window` or  `[cl]open`?  Which
rule should we follow to decide?

## ?

Document that  the result of `:vimgrep`  is influenced by `'isk'`  (and probably
`'isf'`, `'isi'`,  ...), if the  pattern contains  something like `\k`  or `\<`,
`\>`. Indeed, if `:vimgrep` searches inside  a file which is currently loaded in
a buffer, it uses the buffer-local value of `'isk'`.

    :sp /tmp/file
    :call append('.', ['foo', 'bar', 'foo#bar'])
    :vimgrep /\<bar/gj %
    /tmp/file  |3 col 1  | bar˜
    /tmp/file  |4 col 5  | foo#bar˜

    :setl isk+=#
    :vimgrep /\<bar/gj %
    /tmp/file  |3 col 1  | bar˜

The previous command shows that `:vimgrep` is influenced by the local value of `'isk'`.

    :bd
    :vimgrep /\<bar/gj /tmp/file
    /tmp/file  |3 col 1  | bar˜
    /tmp/file  |4 col 5  | foo#bar˜

But *not* if the buffer where the search is performed is unloaded.

## ?

Install a `!j` mapping which would open an interactive window, in which we could
see all the running jobs, and stop them.

## ?

Try to remove `get()` whenever you can.
You've used it too much in the past to access the value of a qfl property.

Search for `\C\<get(` in this file and in all our notes/plugins/...

## ?

We've  made  a   fundamental  mistake  in  the  past,  every   time  we've  used
`setqflist()` or `setloclist()`.

MRE:

    :CFreeStack
    :helpgrep vim
    :helpgrep fast
    :helpgrep unix
    :helpgrep text
    :helpgrep editor
    :colder 3
    :chistory
    :call setqflist([], ' ')
    :chistory

When you invoke `setqflist()`, all the qfl after the current one are removed.
That's why `vim-asyncmake` sets the `nr` property to `$`:

    call setqflist([], ' ', {'nr': '$',
    ...

---

The same issue exists whenever we've executed `:make`, `:grep`, `:vimgrep`, ...

Before executing any of  those commands, you should make sure  you're at the top
of the stack:

    :let stack_size = getqflist({'nr': '$'}).nr
    :let current_qfl = getqflist({'nr': 0}).nr
    :execute (stack_size - current_qfl) .. 'cnewer'

Maybe you should  use a library function (`lg#...()`), which  would take care of
all those kind of details, and would  set the qfl without altering the stack too
much.

    :ConfigGrep -filetype=vim [cl]\%(add\|get\)\=\%(expr\|file\|buffer\)\|l\=make\|l\=vim\%[grep]\%(add\)\=\>.*/[^/]*/[gj]\{1,2}

## ?

Document that `:[cl]history` can be prefixed by a count.
Doing so lets you select an arbitrary qfl in the stack.

## Add a flag in the tab line to warn us when an async command has terminated populating a qfl.

Make the flag disappear once we've visited the qf buffer.

## Install a custom command to filter the qfl with fzf.

Maybe have a look at this for inspiration:
<https://gist.github.com/davidmh/f35fba1f9cde176d1ec9b4919769653a>

## The qfl is altered if you delete a line, even if you undo right after.  Bug?  Improvement to ask on github?

    $ vim -Nu NONE +'vim /a\|c/gj %' <(echo "a\nb\nc\nd")
    " press `j` to focus the line containing `b`
    " press `gwj` to format the line `b` with the line `c`
    " press `u` to undo
    :cnext
    (2 of 2) (line deleted): c˜

After `:cnext`, the cursor is positioned on line `d`; I would expect line `c`.
Besides, the qfl has been altered:

    :echo getqflist()[1]
    {'lnum': 4, 'bufnr': 1, 'col': 1, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': 0, 'type': '', 'module': '', 'text': 'c'}˜

The value of the key `lnum` has changed from `3` to `4`.

In practice, because of this issue, when you edit some text in a buffer in which
there are some qf entries, sometimes, when jumping to a qfl entry, you end up in
an unexpected  location, which  doesn't match the  pattern which  was originally
used to populate the qfl.

##
## To document:
### Vim always re-uses the *same* quickfix buffer since 8.1.0877

    $ vim -Nu NONE +'silent helpgrep foo' +'echomsg bufnr() | close' +'silent helpgrep bar' +'echomsg bufnr()'
    2
    2

It doesn't matter  whether you close and then re-open  the same quickfix window,
or you  open a  new quickfix  window in  a new  tab page,  or you  stack several
quickfix lists, or whatever... Vim *always* re-uses the *same* buffer.

Obviously, the contents of that buffer is updated whenever you use a new command
to populate a  new quickfix list; but  the quickfix list is  always displayed in
the same buffer.

Same thing for  the location list buffer;  but with one twist:   Vim re-uses the
same buffer  *per window*.   Remember that  a location  list is  bound to  a Vim
window.

All of this matters if you try to  limit the scope of an autocmd to a particular
qf list.  As a result, this doesn't work anymore:

    autocmd BufWinEnter <buffer> " do sth

Solution:  Inspect the quickfix id:

    let s:qfid = get(s:, 'qfid', []) + [getqflist({'id': 0})]
    autocmd BufWinEnter <buffer> if index(s:qfid, getqflist({'id': 0})) >= 0 | call s:conceal_noise() | endif
                                 ^-----------------------------------------^
                                                      ✔

See what we  did in `autoload/cookbook.vim` to  conceal a double bar,  only in a
`:Cookbook` qf window.

---

OTOH, the winid is incremented every time you open a new qf window:

    $ vim -Nu NONE +'silent helpgrep foo' +'echomsg win_getid() | close' +'silent helpgrep bar' +'echomsg win_getid()'

    1001˜
    1002˜

But you can't use that info like this:

    let t:_my_qf_window = win_getid()
    autocmd BufWinEnter <buffer> if win_getid() == t:_my_qf_window | do sth | endif
                                 ^-------------------------------^
                                                 ✘

If you do, the autocmd won't be executed  when you display a new qfl (✔), but it
won't be  executed either  when you  re-display the same  qfl after  closing and
re-opening its window (✘).

### curly brackets in the file pattern of a `:vimgrep` command break the expansion of environment variables.

    " grep for 'pattern' in all conf or sh files under /etc
    :vimgrep /pat/ /etc/**/*.{conf,sh}
                             ^       ^

    " same thing, but fails to look into vimrc:
    "     Cannot open file "$MYVIMRC"
    :vimgrep /pat/ /etc/**/*.{conf,sh} $MYVIMRC

    " still fails
    :vimgrep /pat/ /etc/**/*.{conf,sh} `=getenv('MYVIMRC')`

    " works
    :vimgrep /pat/ /etc/**/*.conf /etc/**/*.sh $MYVIMRC

    " also works
    :vimgrep /pat/ /etc/**/*.{conf,sh} | vimgrepadd /pat/gj $MYVIMRC

It makes sense.

Once you start using regex-like metacharacters  (like `{` and `}`), Vim probably
parses the whole file pattern in a regex-like way.
And in a regex, environment variables are not expanded.

    :vimgrep /$TERM/ /tmp/file
    E480: No match: $TERM˜
                    ^---^
                    $TERM was not expanded

IOW, in "regex-like mode", Vim has no way  to know in advance which parts of the
file-pattern should  be parsed in  a regex-like way,  and which parts  should be
parsed as environment variables:

                   can't be parsed as an environment variable...
                   v---v
    :vimgrep /pat/ $HOME/*{.sh,.txt}
                          ^--------^
                          ... because this is parsed in a regex-like way, so everything is parsed similarly

Edit: Are you sure this is not a bug?
Curly  brackets also  prevent  `**`  from matching  nothing  (*anywhere* on  the
command-line):

    $ mkdir -p /tmp/test/dir/sub
    $ cd /tmp/test
    $ echo text | tee dir/{foo,sub/bar}
    $ vim -Nu NONE +'silent vimgrep /text/j {} ./dir/**/*'
    # "text" is found in `bar` but not in `foo`

    :silent vimgrep /text/j x ./dir/**/*
    # `text` is found in `bar` *and* in `foo`

### `:cdo` can be used to repeat a macro on an arbitrary set of locations

    /my pattern
    q .... q
    :vimgrep //gj {files}
    :call getqflist()->reverse()->setqflist()
    :cnoremap norm! @q

You need to  reverse the qfl because  each run of the `q`  macro might transform
the buffer in such  a way that the next locations are no  more valid (need to be
updated).

<https://vi.stackexchange.com/a/21579/17449>

### we can set the current entry in the qfl via `setqflist()` and the 'idx' property

<https://github.com/vim/vim/pull/3701>

### the `module` property is ignored if you set the `quickfixtextfunc` one

##
### if you return `[]` from the function assigned to `'qftf'`, the lines are displayed unchanged

### how to disable the *global option* `'qftf'` for one particular qfl

Just set the `'qftf'` *property* of the qfl to a function which returns an empty list.

Note that you can't use a funcref.

### if the value assigned to `'qftf'` is a script local function, you need to use a funcref

To illustrate the pitfall, write this in `/tmp/a.vim`:

    let items = [{'filename': $VIMRUNTIME .. '/doc/index.txt',
        \ 'lnum': 1124, 'valid': 1, 'text': 'You found it, Arthur!'}]
    call setqflist([], ' ', {'items': items, 'quickfixtextfunc': 's:func'})
    fu s:func(_)
        return []
    endfu
    cwindow
    so /tmp/b.vim

Write this in `/tmp/b.vim`:

    nno cd <cmd>copen<cr>
    nno ci <cmd>call Func()<cr>
    fu Func()
        copen
    endfu

Start Vim like this:

    $ vim -Nu NONE -S /tmp/a.vim

    :quit
    " press:  'cd'
    E120: Using <SID> not in a script context: s:func˜

    :quit
    " press:  'ci'
    E117: Unknown function: s:func˜

I think  that the  code which handles  the `'quickfixtextfunc'`  property shares
some  code with  the  one  code which  handles  the `'quickfixtextfunc'`  global
option.  And you can't write `s:` in an option value.

The  initial  `:cwindow` from  `/tmp/a.vim`  doesn't  raise any  error,  because
`s:func()` is defined in the same script as the `setqflist()` call.
OTOH, `cd` and `ci` are installed in  another script, so when they run `:copen`,
Vim fails to find `s:func()`.

---

Solution: Use a funcref.

    let items = ...
    call setqflist([], ' ', {'items': items, 'quickfixtextfunc': function('s:func')})
                                                                 ^----------------^
    ...

This requires that `s:func` is defined *before* you call `function()` and `setqflist()`.

##
## Talk about the 'filewinid' property of a location window.

See `:help getloclist()`.

## How to open the qf window from a script, using an autocmd installed elsewhere?

    doautocmd <nomodeline> QuickFixCmdPost copen
    doautocmd <nomodeline> QuickFixCmdPost lopen
    doautocmd <nomodeline> QuickFixCmdPost cwindow
    doautocmd <nomodeline> QuickFixCmdPost lwindow

The last command is wrong; `:copen` is not a valid command to populate a qfl.
However, it doesn't matter.
We can use it to communicate some info to the autocmd opening the qf window:

   - do we  want to open the  window unconditionally, or on  the condition
     it contains at least one valid error?

   - do we want to open the qf window or the location window?

Document somewhere  the fact  that the  pattern used  in a  `:doautocmd` command
doesn't have to be valid.  It can be (ab)used to pass arbitrary info.

---

Also, we've used copen/cwindow/lopen/lwindow, inconsistently in our code.
Clean this mess:

    noautocmd vimgrep /do\%[autocmd]\s*\%(<nomodeline>\)\=\s*QuickFixCmdPost/gj ~/.vim/**/*.vim ~/.vim/**/vim.snippets ~/.vim/vimrc | cwindow

Note that if you use `[c|l]window`, sometimes you'll need to add this after:

    if &bt isnot# 'quickfix'
        return
    endif

To avoid, for example, adding conceal outside a qf buffer.

##
## Why does Vim sometimes mix absolute and relative filepaths for files in the same directory?

MRE:

    /tmp/test/foo
    ├── /tmp/test/foo/file1
    ├── /tmp/test/foo/file2
    └── /tmp/test/foo/file3

    $ cd /tmp/test
    $ vim -Nu NONE foo/file1

    :vimgrep /^/gj ./** | cwindow

        foo/file1    |1 col 1  |
        ./foo/file2  |1 col 1  |
        ./foo/file3  |1 col 1  |


If the  buffer where an  entry is  located was already  loaded prior to  the qfl
being populated, Vim will use a relative filepath.
Otherwise, if the buffer didn't exist or  was unloaded, Vim will use an absolute
(albeit reduced; i.e. cwd → `.`) filepath.

For more info:

- <https://vi.stackexchange.com/a/4816/17270>
- <https://github.com/vim/vim/issues/2846>

## Why does Vim sometimes jump to a wrong location when I press Enter on an entry in the qf window?

MRE:

    " disable `vim-cwd`
    :cd ~/.vim/pack/mine/opt/completion/
    :silent CFreeStack | noautocmd vimgrep /timer_start/gj ~/.vim/**/*.vim | cwindow
    SPC R
    :cd ~/Wiki/
    z(
    ]q
    " Keep pressing `]q` until you find entries whose path is relative, like:
    ""
    "         autoload/completion/custom.vim ...
    "         autoload/completion/spel.vim   ...
    ""
    " You'll end up in a buffer not associated with any file.

Simplify this MRE, so that it doesn't refer to any custom configuration.

## Why does Vim sometimes add `:` at the start of `w:quickfix_title`?

    $ vim -Nu NONE --cmd 'filetype plugin on' \
        +'silent grep --recursive --no-messages foobar /etc' \
        +cwindow
    :echo w:quickfix_title
    :grep -n --recursive --no-messages foobar /etc /dev/null ˜
    ^
    ✘

I would expect `$` or nothing.

---

Vim does not add this leading `:` in the following command:

    $ grepc foobar /etc >/tmp/qfl
    $ vim -Nu NONE --cmd 'filetype plugin on' -q /tmp/qfl +cwindow
    :wincmd w
    :echo w:quickfix_title
    cfile /tmp/qfl˜
    ^
    no leading colon

However, if you run `:cfile /tmp/qfl` again manually:

    :cfile /tmp/qfl

Then Vim adds a second quickfix list whose title contains the leading colon.
This is inconsistent.

## When does Vim expand relative filepaths?

## When does Vim jump to wrong location?

## What's the purpose of 'items'?

It seems we could without it (`:help setqflist-examples`):

    :echo getqflist({'id' : qfid, 'items' : 0}).items
    ⇔
    ??? (no equivalent here)

    I think we couldn't extract the items of a non-current qfl without 'items'.
    Also, I think 'items' lets you replace  the items in a qfl without affecting
    its title.



    :let newItems = [{'filename' : 'a.txt', 'lnum' : 10, 'text' : "Apple"},
                    \ {'filename' : 'b.txt', 'lnum' : 20, 'text' : "Orange"}]
    :call setqflist([], 'a', {'id' : qfid, 'items' : newItems})
    ⇔
    :let newItems = [{'filename' : 'a.txt', 'lnum' : 10, 'text' : "Apple"},
                    \ {'filename' : 'b.txt', 'lnum' : 20, 'text' : "Orange"}]
    :call setqflist(newitems, 'a', {'id' : qfid})


    :call setloclist(3, [], 'r', {'items' : newItems})
    ⇔
    :call setloclist(3, newItems, 'r')
