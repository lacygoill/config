# Do *not* write a guard to prevent this file from being sourced.{{{
#
#     ✘
#     if set --query --export __fish_config_dir
#         exit
#     end
#
# For example, you might be tempted to do that to prevent duplicate entries from
# being added in a  `*PATH` variable when we start tmux  (the latter might start
# yet another fish process via its `default-command` option).
#
# Don't.  It would consolidate all elements in lists:
#
#     set --export foobar a b c
#     # start fish from bash, then run:  set --show foobar
#     $foobar: set in global scope, exported, with 3 elements
#                                                  ^
#                                                  ✔
#     $foobar[1]: |a|
#     $foobar[2]: |b|
#     $foobar[3]: |c|
#
#     # start a fish subshell, and run:  set --show foobar
#     $foobar: set in global scope, exported, with 1 elements
#                                                  ^
#                                                  ✘
#     $foobar[1]: |a b c|
#     $foobar: originally inherited as |a b c|
#
# That  might  have  undesirable  consequences.  For  example,  it  might  break
# `mpv(1)`'s  completion in  tmux,  because `FIND_OPTS`  expansion  needs to  be
# splitted on whitespace.
#
# ---
#
# Note that the issue does not affect any variable whose name ends with `PATH`:
#
#    > Fish  automatically  creates lists from all environment variables whose
#    > name ends in PATH (like PATH, CDPATH or MANPATH), by splitting them  on
#    > colons. Other variables are not automatically split.
#
# Source: `man fish-language /SHELL VARIABLES/;/Lists/;/MANPATH`
#}}}

# __fish_* {{{1
# Warning: Leave this fold at the top.
# We might need to refer to the value of a `__fish_*` variable later.
# For example, `$MANPATH` needs `$__fish_data_dir`.

# By default, those are set but not exported.
# We want them to be exported to be able to read them from other programs (e.g. Vim).
set --export __fish_config_dir $__fish_config_dir
set --export __fish_data_dir $__fish_data_dir
set --export __fish_sysconf_dir $__fish_sysconf_dir

# BROWSER {{{1

# Some programs inspect this variable to determine which program to start.{{{
#
# For example, `man(1)` when we run `$ man --html man`.
# If it's not set, they fall back on some value.
# `man(1)` seems to fall back on `links(1)`.
# We don't know `links(1)` well, and we haven't configured it.
#}}}
set --export BROWSER firefox

# CONTAINERS_CONF {{{1

# We need this variable to be set to  be able to preserve our config when we run
# `podman(1)` with `sudo(8)`:
#
#    > If the CONTAINERS_CONF environment variable is set, then its value is
#    > used for the containers.conf file rather than the default.
#
# Source: `man podman /CONFIGURATION FILES/;/CONTAINERS_CONF`:
set --export CONTAINERS_CONF $HOME/.config/containers/containers.conf

# COLORTERM {{{1

# Make sure applications know that our terminal supports true colors.{{{
#
#    > Make sure that  your truecolor terminal sets the  `COLORTERM` variable to
#    > either  `truecolor` or  `24bit`.  Otherwise,  `bat` will  not be  able to
#    > determine whether or not 24-bit  escape sequences are supported (and fall
#    > back to 8-bit colors).
#
# Source: https://github.com/sharkdp/bat#terminals--colors
#
#    > VTE,  Konsole  and iTerm2  all  advertise  truecolor support  by  placing
#    > COLORTERM=truecolor in  the environment  of the shell  user's shell.
#    > [...]
#    > Having  an extra environment  variable (separate from  TERM) is not  ideal:
#    > [...]
#    > Despite  these problems,  it's  currently the  best  option, so  checking
#    > $COLORTERM is recommended  since it will lead to a  more seamless desktop
#    > experience where only one variable needs to be set.
#
# Source: https://github.com/termstandard/colors#checking-for-colorterm
#
# ---
#
# BTW, you can see the effect that this variable has on `bat(1)`:
#
#     $ echo 'text' | bat --color=always --style=plain | vim -Nu NONE -
#
#     # without COLORTERM
#     ^[[38;5;234mtext^[[0m
#             ^^^
#             8-bit color
#             https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
#
#     # with COLORTERM
#     ^[[38;2;17;27;39mtext^[[0m
#             ^------^
#             24-bit color (aka true color)
#             https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
#}}}
# But obviously, not in the console.
if ! string match --quiet --regex -- '^linux' $TERM
    set --export COLORTERM truecolor
end

# CONFIG_FILETYPES {{{1

set --export CONFIG_FILETYPES $HOME/.cache/vim/config_filetypes.json

# ESCDELAY {{{1

# Specifies  the total  time,  in  milliseconds, for  which  ncurses will  await
# a  character  sequence,  e.g.,  a  function  key.   The  default  value,  1000
# milliseconds, is  a bit  too long;  notably when  we use  `tig(1)`.  Nowadays,
# 100ms should be more than enough.
#
# For more info, see `man ncurses /ESCDELAY`.   On Ubuntu, you only get this man
# page if you've installed the package `ncurses-doc`.
#
# See also:
# https://github.com/jonas/tig/blob/d072cb7829ca187e4bb36f22e34b7bdd70dd5491/TROUBLESHOOTING.adoc#escdelay

set --export ESCDELAY 100

# GNUPGHOME {{{1

set --export GNUPGHOME $HOME/.config/gnupg/

# INFO_PRINT_COMMAND {{{1

# If we execute `info(1)` without redirecting  its output to an editor, we still
# want the ability to press `E` to pipe  the contents of the current node to our
# editor (like in `less(1)`).
set --export INFO_PRINT_COMMAND 'vim --not-a-term -'

# INTERACTIVE_SHELL {{{1

# Some programs (e.g. tmux, Vim) might need to start an interactive shell.
# Let's use this variable to tell them which one.
set --export INTERACTIVE_SHELL $(type --path fish)

# IRBRC {{{1

# Necessary to prevent `irb(1)` from creating `~/.irb_history`.
set --export IRBRC $HOME/.config/irbrc

# LESSKEYIN {{{1

set --export LESSKEYIN $HOME/.config/less/keys

# LS_COLORS {{{1

# Ask `dircolors(1)`  to read  its config from  `~/.config/dircolors/config`, so
# that it  sets `LS_COLORS`.  The  latter controls the  colors in the  output of
# `$ ls --color`.

# If you don't export this variable, fish might do it after you execute an `ls` command.{{{
#
# That's because, by default, `ls` is a fish function:
#
#     $ type ls | head --lines=3
#     ls is a function with definition
#     # Defined in /usr/local/share/fish/functions/ls.fish @ line 20
#     function ls --description='List contents of directory'
#
# It's defined here:
#
#     $__fish_data_dir/functions/ls.fish
#
# And it seems that this function can have the side-effect of setting `LS_COLORS`.
#}}}
#   But you still need to set it here.{{{
#
# Because the first  command that you execute and which  reads `LS_COLORS` might
# not be `ls`  (e.g. another program might  assume its existence and  read it to
# colorize its output).  If that's the case, we want our config to be taken into
# account immediately.
#}}}

if ! test -s "$HOME/.cache/fish/dircolors"
    dircolors $HOME/.config/dircolors/config \
  | sed -n 's/^LS_COLORS=/set --export LS_COLORS /p' \
    >$HOME/.cache/fish/dircolors
end
source $HOME/.cache/fish/dircolors

# LUA_INIT {{{1

# For pretty-printing values:{{{
#
#     > pp({ a = 1, b = 2 })
#     {
#       a = 1,
#       b = 2
#     }
#
# Require the `inspect` rock to be installed.
#}}}
set --export LUA_INIT 'pp = function(obj) print(require("inspect")(obj)) end'

# MAN* {{{1

# See: `:help manpager.vim`
# Don't put quotes around `Man!`.{{{
#
# We don't have the guarantee that a shell will always remove them.
#
# For example:
#
#                                   ✘    ✘
#                                   v    v
#     $ set --export MANPAGER 'vim +"Man!" --not-a-term -'
#     $ set --export SYSTEMD_PAGER $MANPAGER
#     $ systemctl help default.target
#     # expected: the buffer is processed by :Man
#     # actual: the buffer is not processed
#
# The  buffer  is  not processed  because  for  Vim  `"`  is a  comment  leader;
# everything afterward is ignored.
#
# Same issue with single quotes:
#
#                                   ✘    ✘
#                                   v    v
#     $ set --export MANPAGER "vim +'Man!' --not-a-term -"
#     $ set --export SYSTEMD_PAGER $MANPAGER
#     $ systemctl help default.target
#     Error detected while processing command line:
#     E16: Invalid range
#
# `$ systemctl help` does not invoke a  shell to start `SYSTEMD_PAGER` (contrary
# to `man(1)`  when it  starts `MANPAGER`).   This is  confirmed by  tracing the
# process:
#
#     $ strace --output=$TMPDIR/trace.log -f --trace=execve systemctl help default.target
#
#     12345 execve("/usr/local/bin/vim", ["vim", "+'Man!'", "--not-a-term", "-"], ...
#                                                  ^    ^
#                                                  ✘    ✘
# ---
#
# Note that we don't set `SYSTEMD_PAGER` like `MANPAGER` because it would affect
# all systemd commands (not just  `$ systemctl help`).  And `:Man` is not suited
# for all of them (e.g. `journalctl(1)`).
#}}}
set --export MANPAGER 'vim +Man! --not-a-term -'

# Don't use ANSI escape codes for bold/italic/underline attributes.{{{
#
# Use backspaces instead.
# This matters for our Vim `man` plugin, which expects backspaces.
#
# ---
#
# Alternative:
#
#     set --export GROFF_NO_SGR yes
#
# But the latter has a broader  effect.  `MANROFFOPT` only applies when `man(1)`
# is invoked, leaving `grotty(1)` free to output SGR in other contexts.
#
# ---
#
# https://bbs.archlinux.org/viewtopic.php?id=287185
# https://felipec.wordpress.com/2021/06/05/adventures-with-man-color/
# https://unix.stackexchange.com/questions/243953/how-do-i-generate-manpages-using-escape-codes-for-bold-etc
#}}}
set --export MANROFFOPT -c

# Purpose:{{{
#
# Write the word `printf` in a markdown buffer, then press `K`.
# `man(1)` will give to Vim the `printf` page from the section 1.
# But what if you prefer to give the priority to the section 3?
#
# That's where `MANSECT` comes in.
# It lets you change the priority of the man sections.
# Here, I export the default value given in:
#
#     /etc/manpath.config
#
# Use this `--export` statement to change the priority of the sections.
#
# Note that  pressing `3K` or  executing `man 3 printf`  will give you  the page
# from the section 3, no matter  what `MANSECT` contains.  This variable is only
# useful for when you don't provide the section number.
#
# See `man 1 man` for more info.
#}}}
set --export --path MANSECT 1 n l 8 3 2 3posix 3pm 3perl 3am 5 4 9 6 7

set --export MANWIDTH 80

# NNN_FCOLORS {{{1

# The value contains 12 hex numbers.
#
# Each  number stands  for  a color  in  xterm palette  (run  our palette  shell
# function to  see it), and is  responsible for coloring certain  types of files
# (e.g. directories, executables, ...).
#
# To use a color  from the palette, you need to convert it  from base 10 to base
# 16; e.g. `123` in base 10 is `7b` in base 16.
#
# See: `man nnn /ENVIRONMENT/;/^\s*NNN_FCOLORS`

#                              executable
#                              vv
set --export NNN_FCOLORS c1e2151c0060a5f7c6d6abc4
#                            ^^      ^^
#                     directory      symbolic link

# *_OPTS {{{1
# FIND_OPTS {{{2

# `-mindepth 1`: Do not process the starting-points themselves (only their contents).{{{
#
# Here, it's useful to not prune `.` (which in effect would prune everything).
#
# Alternatively, you  could assert the presence  of at least one  more character
# after the dot in the name of a hidden node:
#
#     -name '.?*'
#             ^
#
# But `-mindepth 1` is more meaningful.
#}}}
# `\( -name '.*' ... \) -prune`: do not descend into hidden directories.
# Do not prune `tmpfs` file systems.{{{
#
# It   would  prune   the  temporary   file  systems   mounted  on   `/run`  and
# `/run/user/1000`,   which   we   sometimes    use.    For   example,   pruning
# `/run/user/1000` breaks the  tab completion of `mpv(1)` when the  CWD is under
# the  latter (the  completion relies  on the  `_complete_media_files` function,
# which in turn executes `$ find ... $FIND_OPTS ...`).
#}}}
set --export FIND_OPTS -mindepth 1 \
    \( -name '.*' \
    -o -fstype dev \
    -o -fstype proc \
    -o -fstype sysfs \
    -o -fstype udev \) -prune -o

# GCC_OPTS {{{2

# https://stackoverflow.com/a/3376483
set --export GCC_OPTS \
 -O\
 -Waggregate-return\
 -Wall\
 -Wcast-align\
 -Wcast-qual\
 -Wconversion\
 -Werror\
 -Wextra\
 -Wfloat-equal\
 -Wformat=2\
 -Wno-unused-result\
 -Wpointer-arith\
 -Wshadow\
 -Wstrict-overflow=5\
 -Wstrict-prototypes\
 -Wswitch-default\
 -Wswitch-enum\
 -Wundef\
 -Wwrite-strings\
 -pedantic

# `-Wall` causes the compiler to produce warning messages when it detects possible errors.{{{
#
# `-W` can be followed by codes for specific warnings; `-Wall` means “all -W options.”
# Should be used in conjunction with `-O` for maximum effect.
#}}}
# `-Werror` turns all warnings into errors.
# `-Wno-unused-result` suppresses annoying warnings.{{{
#
# For example, without this flag, if you  use `scanf()` to write some input into
# a variable:
#
#     int i;
#     printf("choose an integer: ");
#     scanf("%d", &i);
#     ...
#
# gcc will complain because  you don't do anything with the  return value of the
# function:
#
#     ignoring return value of ‘scanf’, declared with attribute warn_unused_result
#
# It probably wants you to check whether the call succeeded:
#
#         if (scanf("%d", &i) == 1)
#         {
#             printf("%d", i);
#         }
#         else
#         {
#             ...
#         }
#
# See: https://stackoverflow.com/a/7271983
#
# An alternative would be to use a void cast *and* a negation:
#
#     (void) !scanf("%d", &i);
#     ^------^
#
# See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66425#c34
# But it  seems too cumbersome,  considering how frequent  we might need  to use
# such functions.
#}}}
# `-pedantic` issues all warnings required by the C standard.{{{
#
# Causes programs that use nonstandard features to be rejected.
#}}}
# `-Wunreachable-code` has been removed:
# https://gcc.gnu.org/legacy-ml/gcc-help/2011-05/msg00360.html

# SHELLCHECK_OPTS {{{2

# `--check-sourced`:{{{
#
# By  default,   shellcheck  only   analyzes  the   scripts  specified   on  the
# command-line.  We want *all* scripts to  be analyzed; including ones which are
# `source`d from a script.
#}}}
set --export SHELLCHECK_OPTS '--check-sourced'
# }}}1
# PARINIT {{{1

# Why this value?{{{
#
# It's recommended in `man par`.
#
# It's useful to prevent the following kind of wrong formatting:
#
#     par <<< 'The quick brown fox jumps over the lazy dog.
#     The quick brown fox jumps over the lazy dog foo bar baz.'
#
#         The quick brown fox jumps over the lazy dog.
#         The quick brown fox jumps over the lazy dog foo bar baz                .    ✘
#
# With the right value for `PARINIT`:
#
#         The quick brown fox jumps over the lazy dog.  The quick brown fox jumps
#         over the lazy dog foo bar baz.                                              ✔
#}}}
# TODO: Finish explaining the value (meaning of options, body/quote characters).
set --export PARINIT 'rTbgqR B=.,?_A_a Q=_s>|'
#                     ├────┘ │ │││├┘├┘ │ ├┘││{{{
#                     │      │ ││││ │  │ │ │└ literal `|` (for diagrams)
#                     │      │ ││││ │  │ │ └ literal `>` (for quotes in markdown)
#                     │      │ ││││ │  │ │
#                     │      │ ││││ │  │ └ whitespace
#                     │      │ ││││ │  │
#                     │      │ ││││ │  └ set of quote characters
#                     │      │ ││││ │
#                     │      │ ││││ └ [a-z]
#                     │      │ │││└ [A-Z]
#                     │      │ │││
#                     │      │ ││└ literal `?`
#                     │      │ │└ literal `,`
#                     │      │ └ literal `.`
#                     │      │
#                     │      └ set of body characters
#                     │
#                     └ boolean and numerics options (probably)
#}}}

# PASSPHRASE_FILE {{{1

set --export PASSPHRASE_FILE $HOME/.config/gnupg/passphrase

# PATH {{{1
# To support texlive:{{{
#
#     # https://www.tug.org/texlive/doc/texlive-en/texlive-en.html#x1-310003.4.1
#     set --export --path INFOPATH $HOME/texlive/2021/texmf-dist/doc/info $INFOPATH
#
#     # man page
#     set --export --path MANPATH \
#         ...
#         $HOME/texlive/2021/texmf-dist/doc/man \
#         ...
#
#     # PATH
#     fish_add_path $HOME/texlive/2021/bin/x86_64-linux
#}}}

# CDPATH{{{2

# In the past, we assigned it this value:
#
#     set --export --path CDPATH '' $HOME $HOME/Downloads $HOME/VCS $HOME/Wiki $XDG_RUNTIME_DIR
#
# But I don't like the fact that it makes `cd` somewhat unpredictable.
# Besides, the `j` alias (provided by  the frec plugin) serves a similar purpose,
# but does it in a much more powerful way.

# GOPATH {{{2

# https://github.com/golang/go/wiki/SettingGOPATH#fish
set --export --path GOPATH $HOME/.local/go

# LD_LIBRARY_PATH {{{2
# Warning: Never set this variable in a shell startup file, nor when compiling.{{{
#
# It's the number one cause of all shared library problems.
#
# First, when  looking for  a shared  library, `ld.so(8)`  must search  – many
# times – through  the entire contents of each  directory in `LD_LIBRARY_PATH`
# (separated by colons) before the  ones from `/etc/ld.so.cache`.  That causes a
# big performance hit.
#
# Second, this variable will  affect every program that you run.   If you use it
# to add a directory for one particular program, you might break another program
# (because of a mismatched library).
#}}}

# This is  a cheap way  to make a  program work when it  needs to find  a shared
# library in a  new directory, and you  can't re-compile it (you  don't have its
# source code, or it's too complex, or it would take too much time).
#
# If you really need it to run some program, then use a wrapper script:
#
#     #!/bin/sh
#     export LD_LIBRARY_PATH='/path/to/some/lib/directory'
#     exec /path/to/some/binary "$@"

# LUA_PATH, LUA_CPATH {{{2

if ! test -s "$HOME/.cache/fish/lua_path"
    set --local lua_version $(LUA_INIT= lua -e 'print(_VERSION:match("%d+\.%d+"))')
    # Where did you get the value?{{{
    #
    #     $ luarocks path
    #}}}
    # Why don't you use `--path`?{{{
    #
    # It  wouldn't work,  because  the Lua  interpreter uses  a  semicolon as  a
    # delimiter between 2 paths instead of the usual colon.
    #}}}
    # Why do you quote the value?{{{
    #
    # It contains question marks which the shell parses as wildcards to expand.
    # We don't want the shell to try to expand them; it would give errors.
    #}}}
    # What's the double semi-colon at the end?{{{
    #
    # It stands for the default path:
    # https://www.lua.org/manual/5.1/manual.html#pdf-package.path
    #}}}
    printf 'set --export LUA_PATH "$HOME/.luarocks/share/lua/%s/?.lua;$HOME/.luarocks/share/lua/%s/?/init.lua;;"' \
        $lua_version $lua_version >$HOME/.cache/fish/lua_path
    printf '\nset --export LUA_CPATH "$HOME/.luarocks/lib/lua/%s/?.so;;"' $lua_version >>$HOME/.cache/fish/lua_path
end
source $HOME/.cache/fish/lua_path

# MANPATH {{{2

# add man pages for `fish`, `fzf`, and `kitty`
# Why do fish man pages need a special treatment? {{{
#
# fish has a lot of man pages.
# A few of them are in an expected location:
#
#     /usr/share/man/man1/fish.1.gz
#     /usr/share/man/man1/fish_indent.1.gz
#     /usr/share/man/man1/fish_key_reader.1.gz
#
# Those are fine; they can be found from anywhere:
#
#    - bash shell
#    - fish shell
#    - `:Man`
#
# But the rest of them are in an unexpected location:
#
#     /usr/share/fish/man/man1/abbr.1
#     /usr/share/fish/man/man1/alias.1
#     /usr/share/fish/man/man1/and.1
#     ...
#
# Those are in an UNexpected location.
# If we don't  include `/usr/share/fish` in `MANPATH`, we won't  be able to read
# them in a different  shell (e.g. bash); we won't even be able  to read in fish
# if we use `:Man`.
#
# Note that in a fish shell, `man(1)` is actually a function:
#
#     $ type man
#     man is a function with definition
#     Defined in /usr/share/fish/functions/man.fish @ line 6
#}}}
#
# Do not prepend directories every time a new fish (sub)shell is started.
if test -z "$MANPATH"
    # These elements are in the default value of `MANPATH`.{{{
    #
    #     # from the start menu of your DE
    #     $ xterm -e bash --norc --noprofile
    #     $ manpath | tr ':' '\n'
    #     $HOME/.local/share/man
    #     /usr/local/man
    #     /usr/local/share/man
    #     /usr/share/man
    #
    # They are absent in fish, because they come from `/etc/manpath.config` which is
    # ignored as soon as you set `MANPATH`:
    #
    #     $ manpath
    #     manpath: warning: $MANPATH set, ignoring /etc/manpath.config
    #                                     ^--------------------------^
    #     ...
    #}}}
    # `~/.local/share/man` is for programs installed locally (instead of system-wide).{{{
    #
    # Those are typically (but not necessarily) Python scripts installed with `pip(1)`.
    #}}}
    # You could also use the element `::`.{{{
    #
    # In that case, `/etc/manpath.config` is  not ignored; instead, its elements are
    # inserted in `MANPATH` in-between the two consecutive colons.
    #
    # Similarly,   if   `MANPATH`   is   prefixed/suffixed  with   a   colon,   then
    # `/etc/manpath.config` prepends/appends its elements to `MANPATH`.
    #
    # See: `man manpath /ENVIRONMENT/;/MANPATH`
    #
    # However,  I suggest  you don't,  because of  a possible  bug.  If  you do,
    # whatever comes afterward might  be lost when we start Vim  as a man pager,
    # which breaks `:Man`:
    #
    #     $ MANPAGER='vim --not-a-term +"Man!" -' MANPATH='/some/path::/usr/local/share/fish/man' man man
    #     :echo $MANPATH
    #     /some/path
    #     :Man fish-doc
    #     man.vim: No manual entry for fish-doc
    #
    # Note  that the  issue occurs  in bash  but not  in fish.   I guess  that's
    # because fish  automatically splits the  value of  a variable into  a list.
    # And it seems that a list does not suffer from an unexpected truncation.
    #}}}
    set --local default_manpath \
        $HOME/.local/share/man \
        /usr/local/man \
        /usr/local/share/man \
        /usr/share/man

    set --export --path MANPATH \
        $__fish_data_dir/man \
        $HOME/.fzf/man \
        $HOME/.local/kitty.app/share/man \
        $default_manpath \
        $MANPATH
end

# PATH {{{2
# We no longer run any code in this section.{{{
#
# By setting `PATH` in `~/.profile_local`,  instead of calling `fish_add_path` a
# few times here, we save about 100ms.  Besides, it makes `PATH` more consistent
# across environments (bash, fish, graphical login, ...).
#}}}
# But we keep it for the comments.

# Add the most important directories last so that they appear at the start of `$PATH`.
# Note that `fish_add_path` only adds a directory in `$PATH` if it exists.{{{
#
#     $ fish_add_path /does/not/exist; echo $status
#     1
#
# That  should not  prevent  you  from passing  a  non-existing directory.   For
# example, currently, we pass `/usr/local/go/bin` to `fish_add_path` even though
# it fails, because the  directory does not exist.  But it  will succeed once it
# exists; and it will be created once we compile and install go locally.
#}}}

# How does `fish_add_path` add a directory to `$PATH`?{{{
#
# It's prepended to `$fish_user_paths` unless `--append` is given.
# `$fish_user_paths` is itself prepended to `$PATH`, so whatever directories the
# user adds, they still stay ahead of the system paths.
#}}}
# When should I use `--move`?{{{
#
# When   you   want  the   guarantee   that   the   added  directory   will   be
# appended/prepended to the current `$PATH`.
#
# Indeed, if the directory is already present in `$PATH`, `fish_add_path` fails.
#}}}
# How to append a directory to `$PATH`?{{{
#
#     $ fish_add_path --append --path /path/to/dir
#
# This is useful  for a directory which  should only be used as  a fallback when
# all the other ones have failed.
#}}}

# remove duplicate entries in some PATH-like variables {{{2
# Rationale: This is the case with `XDG_CONFIG_DIRS` and `XDG_DATA_DIRS`.
# It can have undesirable effects.
# Warning: Keep this section *after* setting all PATH-like variables.

path-dedup XDG_CONFIG_DIRS XDG_DATA_DIRS
#}}}1
# PDFVIEWER {{{1

# Choose which program should be used to open pdf documents.
# Useful for `texdoc`.
set --export PDFVIEWER zathura

# RLWRAP_HOME {{{1

# For  `rlwrap(1)`  to create  its  history  files in  `~/.local/share/rlwrap/`,
# instead of `~/.COMMAND_history`.
set --export RLWRAP_HOME $HOME/.local/share/rlwrap

# SUDO_ASKPASS {{{1

# The editor might give an error when we try to write a file owned by root using
# `sudo(8)`:
#
#     $ editor file_owned_by_root
#     # edit the file
#     :W
#     Error detected while processing BufWriteCmd Auto commands for "...":
#     sudo: no tty present and no askpass program specified
#
# According to the message, we need to specify an askpass program.
# If you search `askpass`  in `man sudo`, you'll find the  `-A` option (which we
# use in our `vim-unix` plugin) and the `SUDO_ASKPASS` environment variable.

# Where did you find this `/usr/lib/ssh/x11-ssh-askpass` file?{{{
#
# It's provided by the `ssh-askpass` package:
#
#     $ apt-file search --regex 'ssh-askpass$'
#     gcr: /usr/libexec/gcr-ssh-askpass
#     git-cola: /usr/share/git-cola/bin/ssh-askpass
#     ltsp: /usr/share/ltsp/client/login/ssh-askpass
#     lxqt-openssh-askpass: /usr/bin/lxqt-openssh-askpass
#     pssh: /usr/lib/pssh/pssh-askpass
#     seahorse: /usr/libexec/seahorse/ssh-askpass
#     ssh-askpass: /usr/lib/ssh/x11-ssh-askpass
#     ssh-askpass-gnome: /usr/lib/openssh/gnome-ssh-askpass
#
# Also:
#
#     $ apt show ssh-askpass-gnome
#     ...
#     You probably want the ssh-askpass package instead, but this is
#     provided to add to your choice and/or confusion.
#}}}
set --export SUDO_ASKPASS /usr/lib/ssh/x11-ssh-askpass

# SYSTEMD_COLORS {{{1

# Problem: The output of `systemctl(1)` is sometimes hard to read.
#
# Because  some of  its lines  can be  highlighted with  color 185  (some kind  of
# yellow), which is hard to read on a light background.
#
# Solution: Limit the palette to the first 16 ANSI colors.
set --export SYSTEMD_COLORS 16

# SYSTEMD_LESS {{{1

# Make sure systemd invokes `less(1)` with the same options as we do in fish.
set --export SYSTEMD_LESS $LESS

# TERMINFO_DIRS {{{1

# Necessary  for readline  commands such  as `C-u`  to still  work in  the kitty
# terminal after we've logged in as root with `$ sudo --login`.
set --export TERMINFO_DIRS $HOME/.terminfo

# TIGRC_USER {{{1

# path of the user configuration file for `tig(1)`
set --export TIGRC_USER $HOME/.config/tigrc

# TLDR_* {{{1

# Configure the colors and styles of the output of `tldr`.
set --export TLDR_HEADER green bold
set --export TLDR_QUOTE italic
# You can configure it further with these variables:
#     TLDR_DESCRIPTION
#     TLDR_CODE
#     TLDR_PARAM

# TZ {{{1

# Make WeeChat use less CPU.{{{
#
# >     8.3. How can I tweak WeeChat to use less CPU?
# >     ...
# >     Set the TZ variable (for example: export TZ="Europe/Paris"), to prevent frequent access to file /etc/localtime.
#
# https://weechat.org/files/doc/devel/weechat_faq.en.html#cpu_usage
#}}}
set --export TZ Europe/Paris

# UID {{{1

set --export UID $EUID

# VIRTUAL_ENV_DISABLE_PROMPT (python) {{{1

# Don't alter our shell prompt when working in a Python virtual environment.{{{
#
# Otherwise, the prompt is overridden from this file:
#
#     .venv/bin/activate.fish
#
# It merely prepends  the basename of the virtual environment  between parens at
# the start of the prompt.  But:
#
#    - we can't read it (because of our long ruler); it just causes an ellipsis
#      character to be printed
#
#    - we want more control over its appearance (on the right, in a special color)
#
# So, we'll handle a similar ad-hoc flag ourselves in our fish prompt.
#}}}
set --export VIRTUAL_ENV_DISABLE_PROMPT yes

# XDG_* {{{1
# Directories relative to which various kinds of user-specific files should be written.{{{
#
# For more info:
#
#    - `man 7 file-hierarchy`
#    - https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
#}}}

# configuration files
set --export XDG_CONFIG_HOME $HOME/.config

# Cached and non-essential/reproducible  data (e.g. generated by  a program, and
# not based on any user input; just meant to make the program faster).
set --export XDG_CACHE_HOME $HOME/.cache

# Resources shared between multiple packages (e.g. fonts or artwork).
# In practice, this is also often used by programs to store essential/non-reproducible data.{{{
#
# For example:
#
#    - bookmarks
#    - icons
#    - swap files
#    - trash
#    - viminfo
#    - `.desktop` files
#    - `.keyring` files
#    - ...
#}}}
set --export XDG_DATA_HOME $HOME/.local/share
#}}}1
# YTFZF_CHECK_VARS_EXISTS {{{1

# To suppress an error:{{{
#
#     $ ytfzf test
#     /usr/local/bin/ytfzf: 630: export: Illegal option --
#}}}
# Why not setting this in a config file?{{{
#
# ytfzf does support a config file at `~/.config/ytfzf/conf.sh` (`man 5 ytfzf`).
# But for some reason, it doesn't help here.
# I  think that's  because the  error occurs  *before* the  config file  is read
# (which is why the latter is absent from a trace when we start the program from
# fish).
#}}}
set --export YTFZF_CHECK_VARS_EXISTS 0
