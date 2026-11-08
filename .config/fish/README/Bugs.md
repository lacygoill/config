# cannot trim control characters with `string trim`

    $ printf '\x01' | string trim --chars='\x01' | xxd
    00000000: 01                                       .
              ^^

Instead, it interprets `\x01` as a collection of separate characters, which thus
are all trimmed:

    $ printf '111000xxx xxx000111' | string trim --chars='\x01' | xxd
    00000000: 20
              ^^
              space

I don't think it's a bug per se, but should it be made to work?
Or should it be better documented?
Also, how are we supposed to trim a control character with `string trim`?

# cannot complete command containing logical `!` from script

                                              v
    $ fish --command="complete --do-complete '! stat'"
    # no completions
      ^^

The issue disappears if `!` is replaced with `not`:

                                              vvv
    $ fish --command="complete --do-complete 'not stat'"
    # many completions
      ^--^

No issue if we execute the command in an interactive shell:

                              v
    $ complete --do-complete '! stat'
    # many completions
      ^--^

##
# command-line which does not fit screen not redrawn correctly

    $ bind \cx\cx 'commandline -i "echo \'" (seq 1 $LINES)/$LINES "\'"'

Known issue: <https://github.com/fish-shell/fish-shell/issues/7296>

It's  especially and  frequently noticeable  when we  use long  multi-line shell
snippets.  For example, the one which records our desktop with `ffmpeg(1)`.

# wrong cursor position when command-line contains literal tab character

    $ fish --no-config
    $ __fish_config_interactive
    $ set --export VISUAL vim
    $ bind \cx\ce edit_command_buffer

    # press:  C-x C-e
    # in Vim, execute:  :call setline(1, "echo 'ab\tc' some_word")
    # press:  ZZ
    # press:  C-e

Expected: The cursor is on the last character of the line.

Actual: The cursor is on the last but one character.

We found this issue while testing navi.
One of the shell snippets was similar to this:

    # some comment
    echo <user>@<server>

    $ user : echo -e "$(whoami)\nroot"
    $ server : cat /etc/hosts | cut -f2 -d' '

The issue  is triggered by the  fact that some  lines in `/etc/hosts` use  a tab
instead of a space as a delimiter.

It *might* be a known issue:
<https://fishshell.com/docs/current/faq.html#i-m-getting-weird-graphical-glitches-a-staircase-effect-ghost-characters-cursor-in-the-wrong-position>
But there is no working solution given there.
Should it be reported?

# an explicit scope in a `set` command is ignored when evaluating a variable to append it an item

    $ set --local --append foo 123
    $ set --global --append foo 123
    $ set --show foo
    $foo: set in local scope, unexported, with 1 elements
    $foo[1]: |123|
    $foo: set in global scope, unexported, with 2 elements
    $foo[1]: |123|
    $foo[2]: |123|

I think that's because  – in the second assignment –  `foo` evaluates to the
value it was assigned in the first assignment.
I would expect `--global` to force fish to look for `foo` in the global namespace.
Is it working as intended or is it a bug?

##
# function called by key binding
## cannot answer `apt(8)` prompt

MRE:

    $ fish --no-config

    $ bind \cx\cx func

    $ function func
        sudo apt install clamav
    end

    # press C-x C-x
    # give password

Expected: Be able to answer the "Do you want to continue? [Y/n]" prompt.
Actual: Input is ignored.

---

Workaround:

    $ sudo apt --assume-yes install clamav
               ^----------^

Or better yet, don't execute the command directly from the function:

    function func
        commandline --replace 'sudo apt install clamav'
        commandline --function execute
    end

## last line of multiline message is erased

MRE:

    $ fish --no-config

    $ function fish_prompt
        printf '\n$ '
    end

    $ bind \cx\cx func

    $ function func
        commandline --function repaint
        echo '
        aaa
        bbb
        ccc'
    end

    # press C-x C-x

Expected: `ccc` is visible.
Actual: `ccc` is not visible.

With  our whole  config, the  issue is  influenced by  the vertical  position of
the  prompt;  if you're  at  the  bottom of  the  window  (e.g. after  executing
`$ seq $LINES`), neither `bbb` nor `ccc` is visible.

---

Workaround:  Append one or two trailing empty lines to the message.

##
# lack of redraw after `upcase-word`/`downcase-word`

    $ fish --no-config
    $ cd /tmp
    # insert this text on the command-line: abc *
    # press C-a to jump at start of line
    # press M-u to uppercase 'abc'
    # expected: 'abc' is immediately uppercased into 'ABC'
    # actual: 'abc' is uppercased into 'ABC' only after we change the contents
    # of the command-line (insert, append, delete, transpose, ...)

# error message sometimes not correctly printed in terminal

    $ ls /tmp /foo | LESS= less
    # expected: the "no such file" error is printed on the terminal
    # actual: it's temporarily printed in the pager

Note that after  pressing `C-L` in the  pager, the error message  is erased.  It
can no longer be read anywhere (neither in the pager, nor in the terminal).

Also, the issue disappears if you add yet another pipe:

    $ ls /tmp /foo | LESS= less | wc -m

Also, the issue  is specific to fish.   In bash, the error  message is correctly
printed in the terminal.

##
# typo in `$__fish_data_dir/functions/fish_default_key_bindings.fish`

Actual:

   > This is a workaround, there will be additions in **he** future.

Expected:

   > This is a workaround, there will be additions in **the** future.

##
# `man bind`: error about `or` special input function

Actual:

   > or     only  execute the next function if the previous succeeded (note:
   >        only some functions report success)

Expected:

   > or     only  execute the next function if the previous failed (note:
   >        only some functions report failure)

# `man fish-language`: error about autoloading functions

Actual:

   > • A directory for functions  for  all  users  on  the  system,  usually
   >   /etc/fish/functions (really $__fish_**sysconfdir**/functions).

Expected:

   > • A directory for functions  for  all  users  on  the  system,  usually
   >   /etc/fish/functions (really $__fish_**sysconf_dir**/functions).

# `man fish-tutorial`: error about variable substitution

Actual:

   > This  is  known as **variable substitution**, and it also happens in double
   > quotes, but not single quotes:

Expected:

   > This  is  known as **variable expansion**, and it also happens in double
   > quotes, but not single quotes:

Rationale: The term “substitution” is never applied to variables in `man fish-language`.
But “expansion” is.

---

Actual:

   > Unlike other shells, variables are not further split after **substitution**:

Expected:

   > Unlike other shells, variables are not further split after **expansion**:

# `man set-color`: wrong debugging command

Actual:

   > number of colors in terminfo for a terminal. Fish launched as **fish  -d2**
   > will  include  diagnostic messages that indicate the color support mode
   > in use.

Expected:

   > number of colors in terminfo for a terminal. Fish launched as **fish  --debug=term-support**
   > will  include  diagnostic messages that indicate the color support mode
   > in use.

# `man printf`:

Actual:

   > • \xhh hexadecimal number (hh**h** is 1 to 2 digits)

Expected:

   > • \xhh hexadecimal number (hh is 1 to 2 digits)

# `man fish-language /JOB CONTROL`: awkward phrasing

Actual:

   > **Most programs** allow you to suspend **the program**'s execution  and  return
   > control  to  fish  by pressing Control+Z (also referred to as ^Z).

Expected:

   > **Most programs** allow you to suspend **their** execution  and  return
   > control  to  fish  by pressing Control+Z (also referred to as ^Z).

# `man fish-faq /HOW DO I CHECK WHETHER A VARIABLE IS DEFINED?`: typo

Actual:

   > Keep  in  mind  that a defined **variabled** could also be empty, either by

Expected:

   > Keep  in  mind  that a defined **variable** could also be empty, either by

# `man fish_git_prompt /DESCRIPTION`: typo

Actual:

   > In  large  repositories,  this  can take a lot of time, so **it** you may
   > wish to disable it in these repositories  with   git  config  --local

Expected:

   > In  large  repositories,  this  can take a lot of time, so **you may**
   > wish to disable it in these repositories  with   git  config  --local
