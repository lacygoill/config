# Pitfalls
## ?

What should I always do when passing `%` the name of the current filename to a shell command.

Whenever you  used `system()`, `systemlist()`, or  `:!` to run a  shell command,
and it contained a filename, make sure  you used the filename modifiers `:p` and
`:S`.

Among other things, `:p` is useful to prevent a filename beginning with a hyphen
from being interpreted as an option by the shell:

    $ cmd -some_file
          ^
          ✘

    $ cmd /path/to/-some_file
                   ^
                   ✔

---

Edit: I think  most of this  section applies to any  argument passed to  a shell
command (`:S`/`shellescape()`).

Look for `system()`, `systemlist()` everywhere,  and make sure we've always used
`:S`, `shellescape()` (and `:p` for filenames).

##
# I need to pass an argument to an Ex command, and it may contain special characters.  When should I use
## `fnameescape()`?

Use   it    if   the    characters   are    special   on    Vim's   command-line
(`:help cmdline-special`), and your argument is unquoted (outside a string).

Example:

    :edit /tmp/foo
    :buffer #
    :split /tmp/foo#bar
    :echo expand('%:p')
    /tmp/foo/tmp/foobar˜
    ✘

    :edit /tmp/foo
    :buffer #
    :execute 'split ' .. fnameescape('/tmp/foo#bar')
    :echo expand('%:p')
    /tmp/foo#bar˜
    ✔

### Which alternative can I use?

Expand backticks as a Vim expression:

    :edit /tmp/foo
    :buffer #
    :split `='/tmp/foo#bar'`
    :echo expand('%:p')
    /tmp/foo#bar˜
    ✔

See `:help backtick-expansion /=`.

##
## `shellescape()`?

Use it if your argument will be parsed by the shell.

---

`:[l]grep[add]` and `:[l]make` are special cases.   They pass your argument to a
shell command run by `:!`. From `:help :grep`:

   > Just like ":make", [...]

From `:help :make`:

   > This works almost like typing
   >
   >       ":!{makeprg} [arguments] {shellpipe} {errorfile}".

So, with those  commands, not only do  you need to escape  characters special on
the shell's  command-line (with  `shellescape()`), but you  also need  to escape
those which are special on Vim's command-line (with 2nd optional argument):

    $ vim
    :execute 'grep! ' .. shellescape('==#') .. ' $VIMRUNTIME'
    E194: No alternate file name to substitute for '#': grepc '==#' $VIMRUNTIME
    ✘

                                            v----v
    :execute 'grep! ' .. shellescape('==#', v:true) .. ' $VIMRUNTIME'
    ✔

##
## ?

From `~/.vim/autoload/myfuncs.vim:848`:

    " Old Interesting Alternative:
    "
    "     silent! execute 'grep! ' .. shellescape(@", v:true) .. ' .'
    "
    " Even though `:grep` is a Vim command, we really need to use `shellescape()`
    " and NOT `fnameescape()`.  Check this:
    "
    "                         ; is special             % is special
    "                         on shell's               on Vim's
    "                         command-line             command-line
    "    ┌───────────────────┬──────────┬─────────────┬────────────┐
    "    │         @"        │  foo;ls  │  that's     │  foo%bar   │
    "    ├───────────────────┼──────────┼─────────────┼────────────┤
    "    │ fnameescape(@")   │  foo;ls  │  that\'s    │  foo\%bar  │
    "    ├───────────────────┼──────────┼─────────────┼────────────┤
    "    │ shellescape(@")   │ 'foo;ls' │ 'that'\''s' │ 'foo%bar'  │
    "    ├───────────────────┼──────────┼─────────────┼────────────┤
    "    │ shellescape(@",1) │ 'foo;ls' │ 'that'\''s' │ 'foo\%bar' │
    "    └───────────────────┴──────────┴─────────────┴────────────┘
    "
    " `fnameescape()` would not protect `;`.
    " The  shell would  interpret  the semicolon  as the  end  of the  `grep(1)`
    " command, and would execute the rest as another command.
    " This can be dangerous:
    "
    "     foo;rm -rf
    "
    " Conclusion:
    " When you have a command whose arguments can contain special characters,
    " and you want to protect them from:
    "
    "    - Vim       use `fnameescape(...)`
    "    - the shell use `shellescape(...)`
    "    - both      use `shellescape(..., true)`
                                           ^--^
    "                                      only needed after `:!`, `:[l]make`, `:[l]grep[add]`; not in `system(...)`
    "                                      `:!` is the only command to remove the backslashes
    "                                      added by the 2nd non-nul argument
    "
    "                             MRE:
    "                             :split /tmp/foo\%bar
    "                             :silent call system('echo ' .. expand('%')->shellescape() .. ' >>/tmp/log')
    "                             :silent call system('echo ' .. expand('%')->shellescape(1) .. ' >>/tmp/log')
    "
    "                                       $ cat /tmp/log
    "                                           /tmp/foo%bar
    "                                           /tmp/foo\%bar
    "                                                   ^
    "
    " ---
    "
    " Edit: If the argument which can contain  special characters is the name of
    " the  current file,  you  can use  the filename  modifier  `:S` instead  of
    " `shellescape(..., true)`.   It's  less verbose.   `:S`  must  be the  last
    " modifier, and  it can work  with other special  characters such as  `#` or
    " `<cfile>`.
