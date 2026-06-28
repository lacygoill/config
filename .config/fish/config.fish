# Don't load our config if invoked to run a script.
# What is `status`?{{{
#
# A builtin which lets you query fish runtime information.
# Here, we  use it  to test  whether fish  is interactive;  i.e. connected  to a
# keyboard.
#}}}
if ! status is-interactive
    return
end

# Plugins {{{1
# Leave this section at the top, so that we can undo any wrongdoing if necessary.

# What's the typical layout of a plugin?{{{
#
#    > A plugin can be any number of files in a functions, conf.d, and completions directory.
#    > Most plugins consist of a single function, or configuration snippet.
#    > This is what a typical plugin looks like.
#
#     ponyo
#     ├── completions
#     │   └── ponyo.fish
#     ├── conf.d
#     │   └── ponyo.fish
#     └── functions
#         └── ponyo.fish
#
# Source: https://github.com/jorgebucaran/fisher#creating-a-plugin
#}}}
# iterate over our plugins
# Inspiration: https://github.com/jorgebucaran/fisher/issues/640#issue-771658021
for plugin in $__fish_config_dir/plugins/*
    # A plugin might want to provide completions, or autoload functions.  Let's make sure fish can find them.{{{
    #
    # `$fish_complete_path`  and  `$fish_function_path` control  where  fish
    # looks for completions and autoload functions.
    #
    # From `man fish-completions /WHERE TO PUT COMPLETIONS`:
    #
    #    > Completions can be defined on the commandline  or  in  a  configuration
    #    > file,  but  they  can  also be automatically loaded. Fish automatically
    #    > searches through  any  directories  in  the  list  variable  $fish_com‐
    #    > plete_path,  and  any completions defined are automatically loaded when
    #    > needed. A completion file must have a filename consisting of  the  name
    #    > of the command to complete and the suffix .fish.
    #
    # From `man fish-language /FUNCTIONS/;/Autoloading functions/;/fish_function_path`:
    #
    #    > When fish needs to load a function, it searches through any directories
    #    > in the list variable $fish_function_path for a file with  a  name  con‐
    #    > sisting of the name of the function plus the suffix .fish and loads the
    #    > first it finds.
    #    >
    #    > For example if you try to execute something called banana, fish will go
    #    > through  all  directories  in  $fish_function_path  looking  for a file
    #    > called banana.fish and load the first one it finds.
    #}}}
    set fish_complete_path $fish_complete_path[1] $plugin/completions $fish_complete_path[2 .. -1]
    set fish_function_path $fish_function_path[1] $plugin/functions $fish_function_path[2 .. -1]
    # A plugin might have one or several config files.  Source all of them.
    for file in $plugin/conf.d/*.fish
        source $file
    end
end

# Variables {{{1

# Warning: Never set a variable in the universal scope directly.{{{
#
#     set --universal variable value
#     ^-------------^
#            ✘
#
# Instead, use this function:
#
#     set_universal variable value
#     ^-----------^
#            ✔
#}}}
# Rationale: Universal variables can cause unexpected issues.{{{
#
# They are annoying when we try to debug an issue.
# That's why  we have a Vim  autocmd which automatically removes  the file where
# they're saved (`fish_variables`), whenever we write the current script.
#
# Now, suppose we want to debug an issue.
# We temporarily disable our config by writing  a `return` at the top, and write
# the file: `fish_variables` is removed.
# We  start a  new  interactive shell  to make  some  test: `fish_variables`  is
# re-created, but it no longer sets any universal variables.
# All the running shells notice that  `fish_variables` has changed, and read its
# contents: they update their local copy of these universal variables by erasing
# them.
#
# This can break syntax highlighting, or give weird error messages:
#
#     $ history | fzf ''
#     error: missing argument
#     in function '_fish_print_pipestatus' with arguments '\[ \] \| \e\[1m 0'
#             called on line 2 of file ~/.config/fish/config.fish
#     in command substitution
#             called on line 789 of file ~/.config/fish/config.fish
#     in function 'fish_prompt'
#     in command substitution
#
# The first error is expected, but the whole following stacktrace is not.
#}}}
# Exception: Don't use `set_universal` with `--append`.{{{
#
# If `$argv` starts with `--append`, we can't execute this unconditionally:
#
#     set --universal $argv
#
# It would create a duplicate item at the end of the list:
#
#     $ set --local --append foo 123
#     $ set --global --append foo 123
#     $ set --show foo
#     $foo: set in local scope, unexported, with 1 elements
#     $foo[1]: |123|
#     $foo: set in global scope, unexported, with 2 elements
#     $foo[1]: |123|
#     $foo[2]: |123|
#
# I think that's because – in the second assignment – `foo` evaluates to
# the value it was assigned in the first assignment.
# Which  means that  an explicit  scope  (here `--global`)  is ignored  when
# evaluating a variable to append it an item (is that a bug?).
#
# Don't try to handle this issue with more code.
# In particular,  don't assume  that the  first token in  `$argv` is  a variable
# name, nor that  the last one is  the only appended item (not  sure it's always
# true).
#}}}
function set_universal
    if string match --quiet --regex -- '^--append' $argv
        set -f curfunc $(status current-function)
        printf '%s: "--append" not supported in "%s %s"\n' $curfunc $curfunc "$argv" >&2
        return 1
    end
    set --global $argv
    set --universal $argv
end

# `fish_features` lets you set some “feature flags”.{{{
#
# A feature flag provides a mechanism to stage breaking changes.
#
# From `man fish-language /FUTURE FEATURE FLAGS`:
#
#    > Feature flags are how fish stages changes  that  might  break  scripts.
#    > Breaking  changes  are introduced as opt-in, in a few releases they be‐
#    > come opt-out, and eventually the old behavior is removed.
#}}}
#   How do I get the list of all available feature flags?{{{
#
#     $ status features
#}}}

# What does `qmark-noglob` do?{{{
#
# It suppresses the special meaning of `?`.
# It is no longer a single-character glob.
#
# Rationale: The special meaning is problematic in unquoted URLs.
#}}}
set_universal fish_features qmark-noglob

# no greeting
set --global fish_greeting

# Key Bindings {{{1
# To find the syntax for a given key: `$ fish_key_reader`
# execute {{{2

# Purpose: Support heredocs and command substitutions.
# Don't try to re-implement this feature using a `preexec` hook.{{{
#
# It wouldn't work.  We can't edit the command-line from this hook.
# See: https://github.com/fish-shell/fish-shell/issues/7470
#}}}
bind \r my-execute

# insert-space {{{2

bind ' ' insert-space
function insert-space
    # Emit an ad-hoc event whenever a space is inserted.{{{
    #
    # This might  be useful  for another  plugin which can  then hook  into this
    # event to execute some arbitrary code.
    #}}}
    #   Emit it *before* the insertion.{{{
    #
    # I *think* it makes plugins' life easier that way.
    #
    # For example, if you emitted the  event *after* the insertion, then, in the
    # `_abbr_reminder` function, you would need to trim the trailing space here:
    #
    #     set -f cmdline $(string join -- ' ' $(commandline --cut-at-cursor))
    #                                         ^----------------------------^
    #}}}
    emit space_inserted
    commandline --insert ' '
end

# kill {{{2

# The default is `backward-kill-path-component` which kills too much.{{{
#
# For example:
#
#     foo bar_baz
#                ^
#                cursor
#
# Expected:
#
#     foo bar_
#
# Actual:
#
#     foo
#}}}
bind \cw backward-kill-word
# `M-DEL`: delete back up to previous whitespace.
# To be consistent with what we did in `$INPUTRC`.
bind \e\x7F backward-kill-bigword

bind \cx\ck kill-buffer
bind \cx\cx kill-kill

# pager {{{2

bind \ch control-h
bind \cj control-j
bind \ck control-k
bind \cl control-l

# miscellaneous {{{2

# By default, `C-a` and `C-e` move at the start/end of a line.
# But, in a multi-line command, it's more useful to jump to the start/end of the
# whole buffer.
bind \ca beginning-of-buffer
# `C-e`  can  also  be used  to  accept  an  autocompletion,  hence why  we  set
# `_cmdline_not_typed_manually`  (to  disable  a possible  useless  abbreviation
# reminder).
bind \ce 'set --global _cmdline_not_typed_manually yes; end-of-line-or-buffer'

bind \t my-complete
bind \c^ 'cd -; commandline --function repaint'

# We never want `C-f` to accept *all* of an autosuggestion.  Only one of its characters.{{{
#
# By default, `C-f` is bound to `forward-char`.
# If  we're at  the end  of the  command-line, and  there is  an autosuggestion,
# `forward-char`  accepts  the  whole  of   it.   This  is  too  unexpected  and
# distracting.
#
# If we want to accept the whole autosuggestion, we can still press `C-e`, which
# is more intuitive.
#}}}
bind \cf forward-single-char

# By default, `C-n` and `C-p`  are bound to `down-or-search` and `up-or-search`.
# Their behavior  is too  complex, which  often makes them  hard to  predict and
# non-intuitive.  Let's try to simplify them.
bind \cn down-or-search-wrapper
bind \cp 'set --global _cmdline_not_typed_manually yes; up-or-search-wrapper'
function _cmdline_not_typed_manually_reset --on-event=fish_postexec
    set --erase --global _cmdline_not_typed_manually
end

# This key binding won't prevent us to put a foreground process in the background.{{{
#
# When we press  `C-z` while a process  is in the foreground,  it's probably the
# terminal  driver which  intercepts  the keypress  and sends  a  signal to  the
# process to  pause it.   In other  words, `C-z`  should reach  fish only  if no
# process has the control of the terminal.
#}}}
bind \cz save-input-and-resume

bind \cg\cg navi-snippets
bind \cg\co omni-TUI

bind \cq quote-path

# let us insert a space without triggering an abbreviation expansion
bind \cv\x20 'commandline --insert " "'

bind \cx\ce edit_command_buffer
bind \ev ''

# supercharge `M-b` and `M-f` to also move in the directory history
bind \eb prevd-or-backward-word-wrapper
bind \ef nextd-or-forward-word

bind \ee ''
# By accident, we might press `M-h` instead of `M-b`.{{{
#
# And by default, `M-h`  is bound to a function which opens the  man page of the
# command at the start of the current line buffer:
#
#     bind --preset \eh __fish_man_page
#
# That's distracting.  We don't want that.
# We don't want to bind it to `*backward-word` either.
# In other programs  which use a readline-like line editor,  `M-h` does not make
# the cursor move 1 word backward; let's be consistent.
#}}}
bind \eh ''
bind \eH man-page-for-command
#      ^
#      *h*elp

bind \ei capitalize-word
bind \eo downcase-word

# By  default, `M-l`  is bound  to `__fish_list_current_token`  which lists  the
# contents of the directory under the  cursor.  For now, this seems useless.  If
# I  want  to list  the  contents  of the  directory  under  the cursor,  I  can
# tab-complete  it (which  leaves  no output  in the  terminal  contrary to  the
# aforementioned function).   And if we press  `M-l` by accident, the  output is
# confusing.
bind \el ''

# `M-Up` (and `M-Down`) is very convenient:{{{
#
#    > • If  the argument you want is far back in history (e.g. 2 lines back -
#    >   that's a lot of words!), type any part of it and  then  press  Alt+↑.
#    >   This  will  show only arguments containing that part and you will get
#    >   what you want much faster.  Try it out, this is very convenient!
#
# Source: `man fish-faq.1 /WHY DOESN'T HISTORY SUBSTITUTION ("!$" ETC.) WORK?`
#
# For example, suppose you have this command-line:
#
#     $ echo foo bar| baz
#                   ^
#                   cursor
#
# And you don't really want to use the argument `bar`; you're just looking for a
# past argument containing  `bar`.  In that case, you just  have to press `M-Up`
# until `bar` gets replaced with the correct argument.
#}}}
# But I don't like the arrow keys.
# Let's re-bind the relevant function to `M-p` (and `M-n`).
bind \en history-token-search-forward
bind \ep history-token-search-backward

# Our tmux `M-s` key binding shadows a default fish key binding:{{{
#
#     $ bind | grep sudo
#     bind --preset \es 'for cmd in sudo doas please; if command -q $cmd; fish_commandline_prepend $cmd; break; end; end'
#
# It's useful to re-run the last command as root.
#}}}
# We restore something similar on `M-S-s`.{{{
#
# The  original  key  binding  calls  `fish_commandline_prepend`  which  doesn't
# prepend  `sudo(8)`  to  the  command-line,   but  to  its  last  process  (see
# `man commandline /--current-process`).   I  think  I prefer  `sudo(8)`  to  be
# prepended to the whole command-line.
#}}}
bind \eS 'commandline --replace "sudo $history[1]"'

# By default, `M-.` is bound to `history-token-search-backward` which we don't like.{{{
#
# It cycles  over *all* arguments of  previous commands.  For this  key binding,
# we're  only interested  in *last*  arguments,  which matches  the behavior  of
# `readline(3)`'s `yank-last-arg` command.
#}}}
bind \e. yank-last-arg
# Cycle  over the  arguments  of  the command  whose  last  argument we've  just
# inserted via `yank-last-arg`.
bind \e, yank-nth-arg
#}}}1
# Abbreviations {{{1
# When should I use a custom command instead of an abbreviation?{{{
#
# When the RHS of an abbreviation becomes too complex to read/maintain.
#
# ---
#
# When you start accumulating too many abbreviations for the same program.
#
# A single  command is easier to  remember than a bunch  of short abbreviations.
# We don't even  need to remember all the subcommands;  the completion remembers
# them for us (provided you write a good one, OFC).
#
# ---
#
# When you need more control.
#
# For example, we  want a simple way  to stage all changed  config files, commit
# the changes, and push to github.
#
# A command lets us control:
#
#    - when files should be completed (i.e. after which subcommands)
#    - which files should be completed
#
# After  `$ config add`,  only  files  in  the  current  working  directory  are
# suggested,  which  is  what  we  want.  With  an  abbreviation,  the  `git(1)`
# completion would  be used.   The latter  would look for  files under  our home
# directory (which contains a huge amount of files):
#
#     $ git --git-dir=$HOME/.cfg/ --work-tree=$HOME ...
#                                             ^---^
#
# That's so slow and so CPU-intensive, that  in practice, you have to cancel the
# completion by pressing `C-c`.
#}}}
# Warning: Do not shadow an existing command.{{{
#
# It could cause an unexpected expansion:
#
#     $ abbr --add df 'df --human-readable'
#                  ^^
#                  ✘
#
#     $ df
#     # press: Enter
#     # This is run:
#     $ df --human-readable
#
#     # Now, press: C-p to recall last expanded command
#     #             C-a to jump at the start of the command
#     #             M-f to jump after the command name
#     #             SPC to start inserting a new option
#
#     # expected:
#     $ df --human-readable
#     # actual:
#     $ df --human-readable --human-readable
#
# The abbreviation has been expanded twice which is not what we wanted.
#}}}

# Regular {{{2
# ... {{{3

function _abbr_dotdotdot
    # outputs `cd ../../` (to expand `...` abbreviation)
    echo cd $(string repeat --count=$(math "$(string length -- $argv[1]) - 1") '../')
end

abbr --add dotdotdot --regex='^\.\.+$' --function=_abbr_dotdotdot

# apt {{{3

abbr --add af apt-file

# Do not use `sudo(8)`.{{{
#
# First, it's not necessary.
# Second, it can give an error:
#
#     W: Download is performed unsandboxed as root as file '....deb' couldn't be
#     accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
#}}}
abbr --add apd 'apt download'

abbr --add api 'sudo apt install'

# purge given package, as well as possible useless lingering dependencies
abbr --add app 'sudo apt purge --autoremove'
# purge *all* packages no longer needed
abbr --add apa 'sudo apt autoremove --purge'

abbr --add aps 'apt show'

# at {{{3

# `-M`: do not send us the output of the job as a mail.
abbr --add at at -M

# colorize {{{3

abbr --add c grc

# Example:
#
#       vv
#     $ du --human-readable --all . | sort --key=1bh,1 | grcat conf.du
#                                                                   ^^
abbr --add CC --position=anywhere --function=_abbr_CC_colorize
#          ^^
#          don't use C; we might sometimes insert it to open a PDF
#          or enter a directory about the C programming language
function _abbr_CC_colorize
    # expand `CC` into `| grcat conf.COMMAND`
    set -f current_process $(commandline --current-process)

    # Special Case: Some commands support `-h` as a short form of `--help`:{{{
    #
    #     $ redshift -h
    #
    # For those, `grcat(1)` is not the right tool; `bat(1)` is:
    #
    #     $ redshift -h | bat --language=help --plain
    #}}}
    if string match --quiet --regex '^\s*\w+\s+-h\b' $current_process
        echo '| bat --language=help --plain'
        return
    end

    set -f tokens $(string split --no-empty -- ' ' $current_process)
    set -f cmd $tokens[1]
    if test "$cmd" = 'sudo'
        set -f cmd $tokens[2]
    end

    # Don't remove the double quotes around `cmd`.
    # We want the abbreviation to be replaced with something no matter what.
    # An abbreviation being replaced with nothing (i.e. deleted) is confusing.
    echo '| grcat conf.'"$cmd"
end

# config {{{3

abbr --add cg 'config jump grep'

# We could add an abbreviation to grep in a given filetype:{{{
#
#     abbr --add --set-cursor=% cgf 'config ls-files --filetype % | xargs --delimiter="\n" grepc --'
#}}}
#   But we don't.{{{
#
# The  previous  abbreviation  does  not  always `grep(1)`  the  same  files  as
# `:ConfigGrep -filetype`.   For  example,  `:ConfigGrep -filetype=python`  will
# also  `grep(1)` into  our `python.snippets`  file.   I don't  like having  two
# commands with the same purpose but with subtle differences.
#
# Anyway,  `$ config grep` and  `:ConfigGrep`  work  in fundamentally  different
# ways.  Let's not fool ourselves into thinking they're the same.
#}}}

# convert2text {{{3

abbr --add ct 'convert2text'

# dl {{{3

abbr --add dl download

# explain-shell {{{3

abbr --add es explain-shell

# extract {{{3

abbr --add xt extract

# ffmpeg {{{3

# FFmepg commands  are too noisy  by default; their  output always start  with a
# copyright notice, build options and library versions.
abbr --add ffmpeg ffmpeg -hide_banner
abbr --add ffplay ffplay -hide_banner -autoexit
abbr --add ffprobe ffprobe -hide_banner

# find {{{3

# `-print`: Prevent an implicit `-print` from being applied to a possible `-prune` contained in `$FIND_OPTS`.{{{
#
#     $ mkdir -p /tmp/test/.hidden && cd /tmp/test
#     $ touch file1 .hidden/file2
#     $ find . -mindepth 1 -name '.*' -prune -o -name '*' -type f
#     ./file1
#     ./.hidden
#     ^-------^
#         ✘
#
# Here, `-prune` was  meant to ignore `.hidden`.  It  was (since `.hidden/file2`
# is  not printed),  but  its  name is  still  unexpectedly  printed because  an
# implicit `-print` was applied to the *whole* expression:
#
#     $ find . -mindepth 1 \( -name '.*' -prune -o -name '*' -type f \) -print
#                          ^^                                        ^^ ^----^
#
# By writing an  explicit `-print`, we make  sure it's only applied  to the last
# predicates (`-name '*' -type f`):
#
#                                                                 v----v
#     $ find . -mindepth 1 -name '.*' -prune -o -name '*' -type f -print
#     ./file1
#}}}
abbr --add --set-cursor=% f 'find . $FIND_OPTS -iname '\''*%*'\'' -type f -print 2>/dev/null'

# fm {{{3

abbr --add fm nnn

# ftp {{{3

# `lftp(1)` is a better FTP client than `ftp(1)`.{{{
#
# It has additional convenience features:
#
#    - multiple-protocol support (including HTTP)
#    - automatic retry on failed downloads
#    - background processes
#    - tab completion of pathnames
#    ...
#}}}
abbr --add ftp lftp

# `lftp(1)` supports SFTP (SSH File Transfer Protocol).{{{
#
# For  some reason,  you only  need to  provide the  correct password  once.  On
# subsequent logins, whatever you type, the next commands will work as expected;
# you can leave it empty.  I guess the credentials are cached.
#
# BTW, something  similar happens  with `sftp(1)`:  you only  need to  give your
# password  for  the first  login  session.   Although, contrary  to  `lftp(1)`,
# `sftp(1)` doesn't  ask for any  password on  subsequent logins (which  is less
# confusing).
#}}}
abbr --add --set-cursor=% sftp lftp sftp://%

# git {{{3

# **g**it **c**heck**o**ut
abbr --add gco git checkout

# grep {{{3

abbr --add g grepc

# locate {{{3

abbr --add lo --set-cursor=% "locate --ignore-case --regex '%'"

# ls {{{3

# `-v`: natural sort of (version) numbers within text
# `--escape`: escape special characters (e.g. `@` or space); don't quote the whole path
# `--time-style` is used to hide the date which is too verbose.
#
# Other possible interesting options:
# `--hyperlink`: useful to open a file by mouse-clicking it.{{{
#
# It makes `ls(1)` create a hyperlink for every listed file.
# Warning: Only some terminals support this feature.
#}}}
#
# The 2nd column contains the number of hard links for a given file/directory.{{{
#
# A file might be given multiple names:
#
#     $ touch file
#     $ ls -l file
#     -rw-rw-r-- 1 ... file
#                ^
#
#     $ ln file other_name
#     $ ls -l file
#     -rw-rw-r-- 2 ... file
#                ^
#
# A directory has at least 2 hard links; its name and its `.` entry:
#
#     $ mkdir dir
#     $ ls -ld dir
#     drwxrwxr-x 2 ... dir/
#                ^
#
# Additionally, its  subdirectories (if any)  each have  a `..` entry  linked to
# that directory:
#
#                  3 subdirectories
#                  v---v
#     $ mkdir dir/{a,b,c}
#     $ ls -ld dir
#     drwxrwxr-x 5 ... dir/
#                ^
#                2 + 3
#
# See: `info '(find)Hard Links'`.
#}}}
abbr --add l "ls -l -v --escape --group-directories-first --human-readable --time-style=+''"

# newsboat {{{3

abbr --add nb 'newsboat --quiet'

# podman {{{3

abbr --add pm podman
abbr --add pmc 'podman container'

# py {{{3

# `-q` to prevent the version and copyright messages from being printed.
# `-i` to enter interactive mode after the command from `-c` has been executed.
# `-c` to import modules:{{{
#
#    - `math` for symbols like `π` (`math.pi`)
#    - `pprint` to pretty-print arbitrary data (e.g. `import os; pp(dir(os))`)
#}}}
abbr --add py 'python -q -i -c "import math, pprint; pp = pprint.PrettyPrinter(indent=4).pprint"'
#                                                    ^----------------------------------------^
# See: https://docs.python.org/3/library/pprint.html

# qmv {{{3

# Available edit formats are:{{{
#
#    - `single-column`       (or `sc`)
#    - `dual-column`         (or `dc`)
#    - `destination-only`    (or `do`)
#
# The default format is dual-column.
#}}}
abbr --add qm 'qmv --format=destination-only'

# sh {{{3

# The default `dash(1)` does not support readline commands.
# You can fix this by compiling it with `--with-libedit`, and by passing `-E` to
# `$ dash` at runtime.  BTW, we have a script to update `dash(1)`; use it.
abbr --add sh 'dash -E'

# systemd {{{3

abbr --add jc journalctl
abbr --add jcu journalctl --user

abbr --add lc loginctl
abbr --add lcu loginctl --user

abbr --add sc systemctl
abbr --add scu systemctl --user

abbr --add sC systemd-cgls

abbr --add sas 'systemd-analyze security'
abbr --add sav 'systemd-analyze verify'

# tail {{{3

# Pipe `tail(1)` to `bat(1)` to get syntax highlighting.
#
#        useful if the file has not been created yet
#                                                   |
#                                                v-----v
abbr --add tl --set-cursor=% 'tail --follow=name --retry % | bat --language=syslog --paging=never'
#                                          ^---^
#                                            |
# useful if the file gets deleted *after* the tail(1) process started

# top {{{3

abbr --add top 'htop'

# tor {{{3

abbr --add tor '~/.local/bin/tor-browser_en-US/Browser/start-tor-browser --detach  # Downloads are in:  ~/.local/bin/tor-browser_en-US/Browser/Downloads'

# trash {{{3

abbr --add tp 'trash put'

# vidir {{{3

# `vidir(1)` is similar to `qmv(1)`.{{{
#
# But it lets you remove files (simply by deleting their lines).
#
# Also,  it can  read  file names  from  STDIN,  which lets  you  operate on  an
# arbitrary subset of the files in the CWD:
#
#     $ find -type f | vidir -
#}}}
abbr --add vd 'vidir --verbose'

# vim {{{3

abbr --add vit 'vim -Nu NONE -S /tmp/t.vim'

# use output of last shell command to populate Vim quickfix list
abbr --add viq 'vim -q $(eval $history[1] | psub) +cwindow'

# vm {{{3

abbr --add vm virt-manager

# web {{{3

# The front page and the results page of duckduckgo is less noisy than google.
# In google, it's much harder to get to the links we want.
abbr --add web 'WWW_HOME=duckduckgo.com w3m'

# yt-dlp {{{3

abbr --add yt yt-dlp

# zathura {{{3

# We don't want the process to be attached to the current shell.
# Fork it into the background
abbr --add zathura 'zathura >/dev/null 2>&1 --fork'
# Alternatively, you could do use `&` and `disown`:{{{
#
#     $ zathura /path/to/file >/dev/null 2>&1 &; disown
#                                             ^-------^
#
# `&` make the process run in the  background (i.e. it doesn't block the current
# shell).
#
# `disown`  prevents  the shell  from  complaining  if  we  try to  exit,  while
# `zathura(1)` is still running. It does so by removing the current job from the
# list of jobs. See `man disown`.
#}}}

# zstd {{{3

# note that `zstd*(1)` utilities also work on `.gz` files
abbr --add zc zstdcat
abbr --add zg zstdgrep
abbr --add zl zstdless
#}}}2
# Typos {{{2

# We sometimes run `!` by accident after quitting Vim.
# It pollutes the history and can cause  unexpected errors when we cycle back to
# a previous command.
abbr --add ! ''

abbr --add ecoh echo

# Anywhere {{{2

function _abbr_bangbang
    echo $history[1]
end
abbr --add !! --position=anywhere --function=_abbr_bangbang

abbr --add G --position=anywhere '| grep -i'
abbr --add H --position=anywhere --set-cursor=% '| bat --language=% --style=plain  # highlight'

# `-+F`: do not quit automatically when entire file can be displayed on first screen.
# `--chop-long-lines`: do not wrap long lines.
abbr --add L --position=anywhere '| less -+F --chop-long-lines'

# **R**edirect **E**rror stream
abbr --add RE --position=anywhere '2>&1'

# **S**ilent
abbr --add S --position=anywhere '2>/dev/null'

abbr --add SO --position=anywhere '| sort'

abbr --add V --position=anywhere '| vipe >/dev/null'
#                                        ^--------^
#                                        don't write on the terminal, the Vim buffer is enough

abbr --add W --position=anywhere '| wc -l'

# Reminder {{{2

# This  section  needs  to  be  run *after*  all  the  abbreviations  have  been
# installed.

# We want to cache the parsing of our abbreviations via universal variables.{{{
#
# Because parsing them every time we start a shell is too inefficient.
# Universal variables give us  the caching for free, but we  still need to write
# the cache only when necessary; not every time we start a shell.
#
# IOW, we need to parse our  abbreviations only if the `fish_variables` file has
# been removed.
#
# Issue:   We can't  reliably  test whether  `fish_variables`  has been  removed
# from here.   For example, `~/.config/fish/conf.d/environment.fish`  is sourced
# before, and  from that  file we  call `fish_add_path`  which sets  a universal
# variable, causing `fish_variables` to be created.
#
# Solution: Test whether an `_ABBR_REMINDER_*` variable has already been set.
#}}}
if ! set --query --universal _ABBR_REMINDER_LHS
    set --erase --universal _ABBR_REMINDER_LHS
    set --erase --universal _ABBR_REMINDER_RHS
    set --erase --universal _ABBR_REMINDER_RHS_LENGTHS
    set --erase --universal _ABBR_REMINDER_LHS_ANYWHERE
    set --erase --universal _ABBR_REMINDER_RHS_ANYWHERE
    set --erase --universal _ABBR_REMINDER_RHS_LENGTHS_ANYWHERE

    set --universal _ABBR_REMINDER_LHS
    set --universal _ABBR_REMINDER_RHS
    set --universal _ABBR_REMINDER_RHS_LENGTHS
    set --universal _ABBR_REMINDER_LHS_ANYWHERE
    set --universal _ABBR_REMINDER_RHS_ANYWHERE
    set --universal _ABBR_REMINDER_RHS_LENGTHS_ANYWHERE

    # Pattern to remove everything before `--` in the output of `$ abbr --show`.
    # We're only interested in the LHS/RHS which are afterward.
    set --local noise '.*?((?:--position\s+anywhere\s+)?--\s+(?:.*))'
    # `string-replace` trims a possible trailing comment:{{{
    #
    #     abbr -a --position anywhere -- SO '| sort --ignore-leading-blanks --stable  # --numeric-sort --reverse'
    #                                                                               ^--------------------------^
    #}}}
    set --local abbrevs $(string replace --regex '\s+#\s+.*$' "'" $(abbr --show))
    set --local anywhere ''
    for abbrev in $abbrevs
        if string match --regex --quiet -- '--(function|set-cursor)[ =]' $abbrev
            continue
        end
        set abbrev $(string match --regex --groups-only -- $noise $abbrev)
        if string match --regex --quiet -- '^--position\s+anywhere' $abbrev
            set abbrev $(string replace --regex -- '^--position\s+anywhere\s+--\s+' '' $abbrev)
            set anywhere '_ANYWHERE'
        else
            set abbrev $(string replace --regex -- '^--\s+' '' $abbrev)
        end
        string match --regex --quiet -- '^(?<LHS>\S+)\s+(?<RHS>.*)' $abbrev
        set --local RHS $(string trim --chars='\'' -- $RHS)
        # The LHS of an abbrev should be shorter than its RHS.{{{
        #
        # If it's not, don't remind us of its existence.
        # It's probably not meant to  be typed voluntarily.  Instead, it's meant
        # to automatically fix an involuntary typo (e.g. `ecoh` → `echo`).
        #}}}
        if test -n "$LHS" && test -n "$RHS" \
                && test "$(string length -- $LHS)" -lt "$(string length -- $RHS)"
            set --universal --append _ABBR_REMINDER_LHS$anywhere $LHS
            set --universal --append _ABBR_REMINDER_RHS$anywhere $RHS
            set --universal --append _ABBR_REMINDER_RHS_LENGTHS$anywhere $(string length -- $RHS)
        end
    end

    # copy universal variables into global namespace
    set --global _ABBR_REMINDER_LHS $_ABBR_REMINDER_LHS
    set --global _ABBR_REMINDER_RHS $_ABBR_REMINDER_RHS
    set --global _ABBR_REMINDER_RHS_LENGTHS $_ABBR_REMINDER_RHS_LENGTHS
    set --global _ABBR_REMINDER_LHS_ANYWHERE $_ABBR_REMINDER_LHS_ANYWHERE
    set --global _ABBR_REMINDER_RHS_ANYWHERE $_ABBR_REMINDER_RHS_ANYWHERE
    set --global _ABBR_REMINDER_RHS_LENGTHS_ANYWHERE $_ABBR_REMINDER_RHS_LENGTHS_ANYWHERE

    # Need to reverse the sorting in case we have two abbreviations which end in the same way.{{{
    #
    # For example, suppose we have these abbreviations:
    #
    #     abbr --add aaa 'yyyy'
    #     abbr --add bbb 'xxxx yyyy'
    #
    # Now, suppose we type:
    #
    #     $ xxxx yyyy
    #
    # We want this reminder:
    #
    #     ✔
    #     bbb => xxxx yyyy
    #
    # Not this one:
    #
    #     ✘
    #     aaa => yyyy
    #}}}
    set_universal _ABBR_REMINDER_RHS_LENGTHS $(printf '%d\n' $_ABBR_REMINDER_RHS_LENGTHS \
        | LC_ALL=C sort --numeric-sort --unique --reverse)
    set_universal _ABBR_REMINDER_RHS_LENGTHS_ANYWHERE $(printf '%d\n' $_ABBR_REMINDER_RHS_LENGTHS_ANYWHERE \
        | LC_ALL=C sort --numeric-sort --unique --reverse)

    set_universal _ABBR_REMINDER_RHS_LENGTH_MIN $(math "min $(string join -- ',' $_ABBR_REMINDER_RHS_LENGTHS)")
    set_universal _ABBR_REMINDER_RHS_LENGTH_MAX $(math "max $(string join -- ',' $_ABBR_REMINDER_RHS_LENGTHS)")
end
#}}}1
# Aliases {{{1
# An alias is equivalent to a function:{{{
#
#     $ alias foo='bar'
#     $ functions foo
#     function foo --description='alias foo=bar'
#         bar $argv;
#     end
#
#     $ alias foo='foo bar'
#     $ functions foo
#     function foo --description='alias foo=bar'
#         command foo bar $argv;
#     end
#
# In the first alias, notice that fish automatically passes all the arguments to
# the `bar` command via `$argv`.
# And in the second alias, notice that  fish prefixes the `foo` command with the
# `command` builtin, to prevent an infinite recursive definition:
#
#     $ function foo
#         foo
#     end
#
#     $ foo
#     fish: The function “foo” calls itself immediately, which would result in an infinite loop.
#     foo
#     ^
#     in function 'foo'
#}}}

# I don't like aliases.  So, this section doesn't have any code.
# In particular, do not alias `sudo(8)`!{{{
#
# First, this is an essential command.
# We should get used to its default behavior.
#
# Second, an alias/function would probably break some commands:
#
#     $ alias sudo='sudo env "PATH=$PATH" '
#     $ sudo -i
#     env: ‘-i’: No such file or directory
#
# Here an error is given because `-i` is passed to `env(1)`.
# That's wrong; it should be passed to `sudo(8)`.
# IOW, you would need to write a function parsing its arguments.
# That's too much work.
#}}}
#}}}1
# Hooks {{{1
# synchronize Vim's local CWD with the shell's one {{{2

if test -n "$VIM_TERMINAL"
    function _vim_sync_PWD --on-variable=PWD
        # in Vim, see `:help 'autoshelldir'`
        printf '\033]7;file://%s\033\\' "$PWD"
    end
end

# emulate `OLDPWD` {{{2

# See:
#    - `man cd`
#    - https://github.com/fish-shell/fish-shell/issues/4040#issuecomment-302128019
function _emulate_OLDPWD --on-variable=dirprev
    set -g OLDPWD $dirprev[-1]
end
#}}}1
# Syntax Highlighting {{{1
# For more info: `man fish-interactive /SYNTAX HIGHLIGHTING/;/Syntax highlighting variables`

# Problem: `--bold` produces colors which are unreadable in the console.
# Solution: Only use it outside.
function set_color_no_bold_in_console --argument-names=token color
    if test -z "$DISPLAY"
        set --global fish_color_$token $color
    else
        set --global fish_color_$token --bold $color
    end
end

# Pager {{{2
# For more info: `man fish-interactive /SYNTAX HIGHLIGHTING/;/Pager color variables`

# progress bar at the bottom left corner
set --global fish_pager_color_progress --reverse magenta

# background color of a line{{{
#
# We use the same color as for the pum in Vim:
#
#     :echo hlget('Pmenu')[0].guibg
#}}}
set --global fish_pager_color_background --background=FFD7D7

# the base string being completed (for every match in the pager)
set --global fish_pager_color_prefix green

# the completing string (for every match in the pager)
set --global fish_pager_color_completion --dim gray

# the description (for every match in the pager)
set --global fish_pager_color_description --dim gray

# background of the selected match
set --global fish_pager_color_selected_background --background=black --dim

# description of the selected match
set --global fish_pager_color_selected_description FFD7D7

# prefix of the selected match
set --global fish_pager_color_selected_prefix white
# suffix of the selected match
set --global fish_pager_color_selected_completion white

# List of extra variables:{{{
#
#     # background of every second unselected match
#     set fish_pager_color_secondary_background red
#
#     # prefix of every second unselected match
#     set fish_pager_color_secondary_prefix red
#
#     # suffix of every second unselected match
#     set fish_pager_color_secondary_completion red
#
#     # description of every second unselected match
#     set fish_pager_color_secondary_description red
#}}}

# Miscellaneous {{{2

# auto-suggestion
set --global fish_color_autosuggestion 6B705C

# the '^C' indicator on a canceled command{{{
#
# *Not* the one which is printed when you press `C-c` while a foreground process
# is running:
#
#     $ sleep 123
#     ^C⏎
#     ^^
#     ✘
#
# The one which is  printed when you press `C-c` *before*  you have executed the
# command:
#
#     $ sleep 123^C
#                ^^
#                ✔
#}}}
set --global fish_color_cancel red

# command name
set_color_no_bold_in_console 'command' green

# command option{{{
#
#     :echo hlget('manOptionDesc', v:true)[0].guifg
#}}}
set_color_no_bold_in_console option 005F5F

# command parameter
set --global fish_color_param blue

# comment{{{
#
#     :echo hlget('Comment', v:true)[0].guifg
#}}}
set --global fish_color_comment 5F875F

# escaped characters like `\n` and `\x70`{{{
#
#     $ echo foo \n bar
#                ^^
#
#     :echo hlget('Special', v:true)[0].guifg
#     #d7875f
#}}}
set --global fish_color_escape D7875F

# error
set_color_no_bold_in_console error red

# history search match{{{
#
# This is  used when  you press  `M-p` to ask  for the  previous command  in the
# history matching what is before the cursor.
#}}}
set --global fish_color_search_match --background=white

# IO redirections like `>/dev/null`{{{
#
#     :echo hlget('Operator', v:true)[0].guifg
#}}}
set --global fish_color_redirection AF5F5F

# keyword
set_color_no_bold_in_console keyword green

# parameter expansion operators like `*` and `~`{{{
#
#     :echo hlget('PreProc', v:true)[0].guifg
#}}}
set_color_no_bold_in_console operator 5F5F00

# process separators like `|`, `;`, `&`
set_color_no_bold_in_console end black

# string{{{
#
#     :echo hlget('String', v:true)[0].guifg
#}}}
set --global fish_color_quote 008787

# valid path{{{
#
# Don't set a color.
# It would be ignored if it's different than `fish_color_param`.
#}}}
set --global fish_color_valid_path --underline

# current position in directory history (as given by `dirh`){{{
#
# `man dirh /fish_color_his‐\_s*tory_current`
#}}}
set_color_no_bold_in_console history_current black
#}}}1
# Prompt {{{1
function fish_prompt #{{{2
# Write out the prompt.
# Adapted from the default: `$__fish_data_dir/functions/fish_prompt.fish`

    # Save `$pipestatus` now.  Its value might change, but we're only interested in its original value.{{{
    #
    # It contains the exit statuses of all processes that made up the last executed pipe.
    # See: `man fish-language /SHELL VARIABLES/;/Special variables/;/pipestatus`
    #
    # `__fish_print_pipestatus` will print it toward the end of the function.
    #}}}
    set -f original_pipestatus $pipestatus

    # `$status` is the exit status of the last foreground job to exit.{{{
    #
    # See: `man fish-language /SHELL VARIABLES/;/Special variables/;/^\s*status`
    #}}}
    #   We save it in an exported variable for `__fish_print_pipestatus`.{{{
    #
    # See: `$__fish_data_dir/functions/__fish_print_pipestatus.fish`
    #}}}
    set -f --export __fish_last_status $status

    # maybe set bold flag for pipestatus
    # status_generation{{{
    #
    # fish automatically increments this numeric  variable whenever it has run a
    # command which produces an explicit exit status.
    #
    #    > the "generation" count of $status.  This will be incremented only
    #    > when the previous command produced an explicit status.
    #    > For  example, background jobs will not increment this.
    #
    # Source: `man fish-language /SHELL VARIABLES/;/Special variables/;/status_generation`
    #}}}
    # If the status was carried over, don't bold it.{{{
    #
    # For example:
    #
    #     $ invalid
    #     invalid: command not found
    #     # next prompt
    #     ~ [127]
    #        ^^^
    #        bold
    #
    #     $ sleep 1 &
    #     # next prompt
    #     ~ [127]
    #        ^^^
    #        not bold, because this is not a new exit status;
    #        it still applies to the same command (`invalid`)
    #
    #     $ set foo bar
    #     # next prompt
    #     ~ [127]
    #        ^^^
    #        not bold, for the same reason
    #}}}
    if test "$status_generation" != "$_last_status_generation"
        set -f bold_flag --bold
    end
    set --global _last_status_generation $status_generation

    # get pipestatus
    # how to highlight the braces around the exit statuses
    set -f status_color $(set_color $fish_color_status)
    # how to highlight the exit statuses themselves
    set -f statusb_color $(set_color $bold_flag $fish_color_status)
    # `__fish_print_pipestatus` is a helper function which expects 6 arguments:{{{
    #
    #    - the left brace to print before the exit statuses
    #    - the right brace to print after the exit statuses
    #    - the separator to print between the exit statuses
    #    - the braces color
    #    - the exit statuses color
    #    - the exit statuses themselves
    #
    # See: `$__fish_data_dir/functions/__fish_print_pipestatus.fish`
    #}}}
    # Do *not* quote `$original_pipestatus`!{{{
    #
    # It could cause unexpected errors;  for example after executing this broken
    # command:
    #
    #     history | fzf ''
    #                   ^^
    #                   ✘
    #
    #     $ Integer 1 in '1 2' followed by non-digit
    #     ~/.local/share/fish/functions/fish_status_to_signal.fish (line 4):
    #             if test "$arg" -gt 128
    #                ^
    #     in function 'fish_status_to_signal' with arguments '1\ 2'
    #             called on line 1 of file ~/.local/share/fish/functions/__fish_print_pipestatus.fish
    #     ...
    #
    # Here is another MRE:
    #
    #                             ✔ ✔
    #     $ fish_status_to_signal 1 2
    #     1
    #     2
    #
    #                             ✘   ✘
    #                             v   v
    #     $ fish_status_to_signal '1 2'
    #     Integer 1 in '1 2' followed by non-digit
    #     ~/.local/share/fish/functions/fish_status_to_signal.fish (line 4):
    #             if test "$arg" -gt 128
    #                ^
    #     in function 'fish_status_to_signal' with arguments '1\ 2'
    #     1 2
    #
    # The issue comes from here:
    #
    #     # $__fish_data_dir/functions/fish_status_to_signal.fish
    #     for arg in $argv
    #                ^---^
    #
    # `$argv` evaluates to  a list of exit  codes, which the loop  expects to be
    # able  to iterate  over  separately.   For this  reason,  they  need to  be
    # *separate* elements, and not joined in a single string.
    #}}}
    set -f prompt_status $(
        __fish_print_pipestatus '[' ']' '|' \
            $status_color $statusb_color $original_pipestatus
    )

    # maybe set job flag
    if jobs --query
        set -f job_flag '[job]'
    end

    # get the  sequence to make  the terminal reset foreground,  background, and
    # all formatting back to default
    set -f reset $(set_color normal)

    # maybe set python virtual environment flag
    if set --query VIRTUAL_ENV
        set -f venv $(string replace --regex '.*/' '' -- "$VIRTUAL_ENV")
        set -f venv $(printf '(%s%s%s)' $(set_color magenta) $venv $reset)
    end

    # Could be used to reliably extract the cwd from the prompt.{{{
    #
    #     /\%#=1.*\%xa0\@=\|^.*
    #
    #     or
    #
    #     /.*\%xa0\|^.*
    #     then trim trailing no-break space
    #
    # This might be useful when you write a plugin/script.
    #}}}
    set -f no_break_space $(printf '\u00a0')

    # the newline lets us start input text at the start of the line
    set -f end \n'٪'

    # no need for a ruler if we've just started a shell and haven't run any command yet
    if test "$status_generation" -eq 0
        set -f ruler ''
    else
        set -f ruler "$(set_color yellow)"$_prompt_ruler\n
    end

    # I want to include the name of my current user and machine!{{{
    #
    # Use the helper function `prompt_login`:
    #
    #     $(prompt_login)
    #
    # It's defined in:
    #
    #     $__fish_data_dir/functions/prompt_login.fish
    #
    # For more info: `man prompt_login`.
    #
    # ---
    #
    # Note that the colors of the names of the host machine, the remote machine,
    # and the logged in user, can all be controlled via variables:
    #
    #     set --universal fish_color_host red
    #     set --universal fish_color_host_remote green
    #     set --universal fish_color_user blue
    #}}}
    # Don't separate `$no_break_space` from the next expression.{{{
    #
    #                    ✔
    #                    v
    #     $no_break_space$prompt_status
    #     $no_break_space $prompt_status
    #                    ^
    #                    ✘
    #
    # We want the no-break space only if `$prompt_status` has a value.
    #
    #    > # Special case: If $c has no elements, this expands to nothing
    #    > >_ echo {$c}word
    #    > # Output is an empty line
    #
    # Source: `man fish-language /PARAMETER EXPANSION/;/Combining lists (Cartesian Product)`
    #}}}
    printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s ' \
        $ruler \
        $(set_color $fish_color_cwd) $(prompt_pwd) \
        $(set_color --bold EE6C4D) $no_break_space$job_flag \
        $no_break_space$(_prompt_shlvl_flag) \
        $reset $no_break_space$(fish_vcs_prompt | string trim --left) \
               $no_break_space$venv \
               $no_break_space$prompt_status \
        $end
end

function fish_right_prompt #{{{2
    # Write out the right prompt.

    # if a command took a lot of time, we want to know how much exactly
    if test "$CMD_DURATION" -lt $(math "1000 * $_MY_TIME_THRESHOLD")
        return
    end
    set -f seconds $(math --scale=0 "$CMD_DURATION / 1000")
    printf 'last command took %s' $(formatted_human_duration $seconds)
end
set --global _MY_TIME_THRESHOLD 60

# Sometimes, we  might want to temporarily  re-define the right prompt  to print
# some info (e.g. reminder about forgotten abbreviation).
# When that happens, we need to restore the original definition.
# So, save it now...
functions --erase fish_right_prompt_original
functions --copy fish_right_prompt fish_right_prompt_original

# ... and restore it after every executed command.
function _restore_fish_right_prompt --on-event=fish_postexec \
--description='make sure fish_right_prompt keeps its original definition, even if temporarily re-defined'
    functions --erase fish_right_prompt
    functions --copy fish_right_prompt_original fish_right_prompt
end

function formatted_human_duration #{{{3
# Input: duration in seconds (e.g. 123)
# Output: human-readable message (e.g. “2 minutes 3 seconds”)
    set -f time $argv
    set -f nums $(_human_duration $time)
    set -f divisions second minute hour
    set -f blue $(set_color blue)
    set -f reset $(set_color normal)
    for n in $(string split -- ' ' $nums)
        if test "$n" -gt 1
            set -f plural 's'
        else
            set -f plural ''
        end
        set -f msg $blue$n$reset $divisions[1]$plural $msg
        set --erase -f divisions[1]
    end
    echo $msg
end

function _human_duration #{{{3
# Input: duration in seconds (e.g. 123)
# Output: list of numbers:{{{
#
#    - [seconds]
#    - [minutes, seconds]
#    - [hours, minutes, seconds]
#}}}
    set -f n $argv
    if test "$n" -ge 3600
        set -f ret $(_human_duration $(math --scale=0 "$n % 3600")) \
                   $(_human_duration $(math --scale=0 "$n / 3600"))
    else if test "$n" -ge 60
        set -f ret $(_human_duration $(math --scale=0 "$n % 60")) \
                   $(_human_duration $(math --scale=0 "$n / 60"))
    else
        set -f ret $n
    end
    echo $ret
end
#}}}2
# fish_color_* {{{2
# Leave these assignments near the prompt definition.{{{
#
# If you move them in the “Syntax Highlighting” section, and you temporarily
# disable/remove it while  debugging an issue, you might  get unexpected errors,
# or some colors might be applied to the wrong text.
#
# Our prompt assumes the existence of these variables.
# Let's make sure to never break this assumption.
#}}}

# current working directory{{{
#
# The default  is green.   We prefer blue,  to be consistent  with the  color of
# directories in the output of `ls(1)`.
#}}}
set --global fish_color_cwd blue

# exit statuses of all processes that made up last executed pipe
set --global fish_color_status '--background=red' 'white'

# fish_git_prompt {{{2
# For more info, see: `man fish_git_prompt`.

# use less plain characters; (e.g. ↑ instead of > for unpushed commits)
set --global __fish_git_prompt_use_informative_chars yes

# show if the repository is “dirty”, i.e. has uncommitted changes
set --global __fish_git_prompt_showdirtystate yes

# show if the repository has untracked files (that aren't ignored)
set --global __fish_git_prompt_showuntrackedfiles yes

# show number of commits ahead/behind (+/-) upstream, but shows nothing when equal
set --global __fish_git_prompt_showupstream 'informative'

# display the state of the stash
set --global __fish_git_prompt_showstashstate yes

# truncate a branch name if it's too long
set --global __fish_git_prompt_shorten_branch_len 20

# describe the current HEAD relative to newer tag or branch, such as (master~4)
set --global __fish_git_prompt_describe_style 'branch'

# enable coloring for the branch name and status symbols
set --global __fish_git_prompt_showcolorhints yes

# for when a merge/rebase/revert/bisect or cherry-pick is in progress
set --global __fish_git_prompt_color_merging 'red'

# for when the repo has “dirty” changes (i.e. unstaged files with changes)
set --global __fish_git_prompt_char_dirtystate 'M'
set --global __fish_git_prompt_color_dirtystate 'red'

# for when the repo has staged files without additional changes
set --global __fish_git_prompt_char_stagedstate 'M'
set --global __fish_git_prompt_color_stagedstate 'green'

# for when the repo has stashes
set --global __fish_git_prompt_char_stashstate '💼'
set --global __fish_git_prompt_color_stashstate 'green'

# for when the repo has untracked files
set --global __fish_git_prompt_char_untrackedfiles '??'
set --global __fish_git_prompt_color_untrackedfiles 'red'

# the color for info about upstream (e.g. unpushed commits)
set --global __fish_git_prompt_color_upstream 'red'

# the color of the branch if it's detached (e.g. a commit is checked out)
set --global __fish_git_prompt_color_branch_detached 'green'

function _set_prompt_ruler --on-event=fish_prompt #{{{2
# set and update a ruler every time a prompt is about to be displayed
    set --global _prompt_ruler $(string repeat --count $COLUMNS '─')
end

function _prompt_shlvl_flag #{{{2
    set -f min_shlvl
    if test "$TERM" = 'linux'
        set -f min_shlvl 1
    else
        set -f min_shlvl 2
    end
    if test -n "$TMUX"
        set -f min_shlvl $(math "$min_shlvl + 1")
    end
    if test -n "$VIM_TERMINAL"
        set -f min_shlvl $(math "$min_shlvl + 1")
    end
    set -f shlvl_flag ''
    if test "$SHLVL" -ge "$min_shlvl"
        set -f shlvl_flag $(printf '[SHLVL=%d]' $SHLVL)
    end
    printf '%s' $shlvl_flag
end
