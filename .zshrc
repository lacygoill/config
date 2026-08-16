# TODO: Finish emptying this file.
# Also, `:ConfigGrep zsh`.  Remove as many occurrences as possible.

# Functions {{{1

function cmdfu { #{{{2
  # Why don't you use the `-R` option anymore (`emulate -LR`)?{{{
  #
  # `emulate -R zsh` resets all the options to their default value, which can be
  # checked with:
  #
  #               ┌ current environment
  #               │         ┌ reset environment
  #               │         │
  #     vimdiff =(setopt) =(emulate -R zsh; setopt)
  #
  # It can be useful, but it can also have undesired effect:
  # https://unix.stackexchange.com/questions/372779/when-is-it-necessary-to-include-emulate-lr-zsh-in-a-function-invoked-by-a-zsh/372866#comment663732_372866
  #
  # Besides, most widgets shipped with zsh use `-L` instead of `-LR`.
  #}}}
  #        │{{{
  #        └ any option reset via `setopt` should be local to the current function,
  #          so that it doesn't affect the current shell
  #
  #          See:
  #              `man zshbuiltins`
  #              > SHELL BUILTIN COMMANDS
  #              > emulate
  #}}}

  if [[ $# -eq 0 ]]; then
    tee >&2 <<EOF
usage: $0 <keyword>
EOF
    return 1
  fi

  # Purpose: {{{
  #
  # Look up keywords on `www.commandlinefu.com`.
  #}}}

  # store our keywords in the variable `keywords`, replacing spaces with dashes
  keywords="$(sed 's/ /-/g' <<< "$@")"
  # store their base64 encoding in `encoding`
  # Could I replace `printf` with `<<<`?{{{
  #
  # No.
  #
  # Watch:
  #
  #         $ printf 'hello world' | base64
  #
  #             → aGVsbG8gd29ybGQ= (✔)
  #
  #         $ base64 <<< 'hello world'
  #         $ printf 'hello world\n' | base64
  #
  #             → aGVsbG8gd29ybGQK (✘)
  #
  # We can't use `<<<` because when the shell expands a “here string”:
  #
  #       The result is  supplied as a single string, WITH A  NEWLINE APPENDED, to the
  #       command on its standard input.
  #
  # The appended newline alters the encoding.
  #}}}
  encoding="$(printf -- "$@" | base64)"

  url="http://www.commandlinefu.com/commands/matching/$keywords/$encoding/sort-by-votes/plaintext"
  if command -v bat >/dev/null; then
    curl --fail --location --show-error --silent "$url" \
    | bat --language=bash --color=always --style=plain | less --ignore-case --RAW-CONTROL-CHARS
    # `--RAW-CONTROL-CHARS`:
    #
    # Don't display control characters used to  set colors; send them instead to
    # the terminal which will interpret them to colorize the text.
    #
    # `--ignore-case`:
    #
    # When  we search  for a  pattern  (`/pat`), ignore  the difference  between
    # uppercase and lowercase characters in the text.
  else
      tee >&2 <<'EOF'
Install `bat` to get syntax highlighting.
EOF
    curl --fail --location --show-error --silent "$url" \
    | less --ignore-case --RAW-CONTROL-CHARS
  fi
}

function grep-pdf { #{{{2
  # Purpose:{{{
  #
  # Grep a pattern in a set of PDF files.
  #}}}
  # Rationale:{{{
  #
  # We can't grep for a pattern in a set of files with any grep-like shell tool.
  #
  # You can in Vim, but you need to visit each buffer so that one of our autocmd
  # converts it from PDF to text.
  # This function takes care of all of that.
  #}}}
  # Tip:{{{
  #
  # You don't  need to re-invoke this  function when you're looking  for several
  # patterns in the *same* set of files.
  # After the function has been invoked  once, the PDFs will have been converted
  # to  text in  Vim buffers,  and you'll  be able  to grep  them as  usual with
  # `:vimgrep` from the current Vim instance.
  #}}}
  # Alternative: pdfgrep utility{{{
  #
  #     $ sudo apt install pdfgrep
  #     $ find /path -iname '*.pdf' -exec /usr/bin/pdfgrep pattern '{}' \+
  #}}}
  if [[ $# -lt 2 ]]; then
    tee >&2 <<EOF
usage:
    $0 'vim regex' file1.pdf file2.pdf ...
    $0 'vim regex' *.pdf
EOF
    return 1
  fi
  local pat="$1"
  # remove the first argument so that `$@` expands to the files,
  # without including the pattern
  # Why `:argdo`?{{{
  #
  # Before we can grep the buffers, they need to be converted to text.
  # We have an autocmd `ReadSpecialFile` in our vimrc to do that.
  # It listens to `BufWinEnter`.
  # So we fire it for every buffer in the arglist.
  #
  # Note that you could use `BufReadPost` too.
  #}}}
  # Why not `:doautoall BufWinEnter` instead?{{{
  #
  # For some reason it doesn't work.
  #
  # According to `:help :doautoall`, the command  works only on loaded buffers; and
  # our PDF buffers, even though not converted yet, are immediately loaded.
  #
  # Also, the help mentions this:
  #
  #     Careful: Don't use this for autocommands that delete a
  #     buffer, change to another buffer or CHANGE THE
  #     CONTENTS OF A BUFFER; THE RESULT IS UNPREDICTABLE.
  #
  # It could explain why `:doautoall` fails.
  #}}}
  # Why `silent!` before `:vimgrep`?{{{
  #
  # If the pattern is absent, I don't want any error message to be printed.
  #}}}
  shift 1
  vim \
  +'argdo doautocmd <nomodeline> BufWinEnter' \
  +"silent! noautocmd vimgrep /$pat/gj ## | cwindow" \
  "$@"
}

function in-fileA-but-not-in-fileB { #{{{1
  if [[ $# -ne 2 ]]; then
    tee >&2 <<EOF
usage:
    $0 <file_a> <file_b>
EOF
    return 1
  fi
  # http://unix.stackexchange.com/a/28159
  # Why `wc --lines <file` instead of simply `wc --lines file`?{{{
  #
  #     $ wc --lines file
  #     5 file
  #
  #     $ wc --lines < file
  #     5
  #
  # I think that when  you reconnect the input of `wc(1)`  like this, it doesn't
  # see  a file  anymore, only  its contents,  which removes  some noise  in the
  # output.
  #}}}
  diff --unified="$(wc --lines <"$1")" "$1" "$2" | sed -n 's/^-//p'
  # TODO: Is that the best method?
  #
  # What about `combine(1)`?
  #
  #     $ combine file1 not file2
  #
  # And what about `comm(1)`.
}

function man-pdf { #{{{2
  if [[ $# -ne 1 ]]; then
    tee >&2 <<EOF
usage: $0 <command name>
EOF
    return 1
  fi
  man_page="$(locate $1 | sed -n "\%share/man/man[^/]*/$1\.%p")"
  # There may be several pages:{{{
  #
  #     $ locate printf | sed -n "\%share/man/man[^/]*/printf\.%p"
  #     /usr/share/man/man1/printf.1.gz˜
  #     /usr/share/man/man3/printf.3.gz˜
  #
  # In that case, grab the first.
  #
  # This explains how to split a string where a newline is:
  # https://stackoverflow.com/a/19772067/9780968
  #}}}
  read man_page <<<"$man_page"
  if [[ -z "$man_page" ]]; then
    printf 'no man page was found for %s\n' "$1"
    return 1
  fi
  # For the `--mode` option, see: https://unix.stackexchange.com/a/462383/289772
  groff -man -Tpdf <(zcat "$man_page") | zathura --mode fullscreen -
  #      │{{{
  #      └ shorthand for `-m man`
  #        include the macro package `man`
  #}}}
}

function mkcd { #{{{2
  # create directory and cd into it right away
  mkdir "$*" && cd "$*"
}

function nstring { #{{{2

  # Description:
  # count the nb of occurrences of a substring `sub` inside a string `foo`.
  #
  # Usage:    nstring sub str

  grep -o "$1" <<< "$2" | wc -l
  #     │       │
  #     │       └ redirection ; `grep` only accepts filepaths, not a string
  #     │
  #     └ --only-matching; print  only the matched (non-empty) parts of
  #                        a matching line, with each such part on a separate
  #                        output line
}

function pdf-merge { #{{{2
  if [[ $# -lt 2 ]]; then
    tee >&2 <<EOF
usage: $0 <output file> <input files>
example: $0 output.pdf *.pdf
EOF
    return 1
  fi

  output_file="$1"
  shift 1

  # https://stackoverflow.com/a/19358402/9780968
  # TODO: Make it preserve hyperlinks.{{{
  #
  # For some people, the output PDF preserves the hyperlinks.
  # https://stackoverflow.com/questions/2507766/merge-convert-multiple-pdf-files-into-one-pdf/19358402#comment94073595_19358402
  #
  # Not for me.
  #}}}
  gs \
     -sDEVICE=pdfwrite \
     -dCompatibilityLevel=1.4 \
     -dPDFSETTINGS=/default \
     -dNOPAUSE \
     -dQUIET \
     -dBATCH \
     -dDetectDuplicateImages \
     -dCompressFonts=true \
     -r150 \
     -sOutputFile="$output_file" \
     $@
}
#}}}2

function stream { #{{{2

  # `mpv(1)` needs `yt-dlp(1)` to read the video from the url.{{{
  #
  # This is possible thanks to the `yt-dlp(1)` hook-script.
  # The  latter looks  at the  input URL,  and plays  the video  located on  the
  # website.  It works with many streaming sites, not just youtube.
  #
  # The `yt-dlp(1)` hook-script is enabled  by default; `--ytdl` is assumed even
  # when omitted.
  #}}}
  if ! command -v yt-dlp >/dev/null 2>&1; then
    printf "yt-dlp is not installed\n"
    return 1
  fi

  if [[ $# -ne 1 ]]; then
    tee >&2 <<EOF
usage:    $0  <video url>
EOF
    return 1
  fi

  local url="$1"
  # `--cache` enables network cache settings.{{{
  #
  # Caching can reduce  the amount of buffering you run  into because the player
  # will have some breathing room between receiving the data and playing it.
  #}}}
  mpv --cache=yes "$url"
}
#}}}2

function vim-fix-vimrc { #{{{2
  # Purpose:{{{
  #
  # Sometimes, you write something in your  vimrc which causes an issue, and you
  # can't start  Vim with your  config anymore (e.g.  an autocmd which  is fired
  # very often and runs a buggy command).
  #
  # When that happens, you need to edit your vimrc with no config:
  #
  #     $ vim -Nu NONE
  #
  # But  doing so  will make  you lose  the undo  history (unless  the vimrc  is
  # currently loaded in your Vim session).
  # To avoid this, you need to set `'undofile'` and `'undodir'` appropriately.
  #}}}
  vim -Nu NONE --cmd 'set undofile undodir=$HOME/.local/share/vim/undo' "$HOME/.vim/vimrc"
}

function vim-prof { #{{{2
  local tmp_file
  tmp_file="$(mktemp)"
  vim --cmd "profile start $tmp_file" --cmd 'profile! file ~/.vim/vimrc' -c 'quitall!'
  vim "$tmp_file" -c 'syntax off' -c '% substitute/\s\+$//' -c 'update'
  rm -- "$tmp_file"
}

function vim-read-plugin-help { #{{{2
  # Purpose:{{{
  #
  # Read the help of a plugin which you don't want to install yet.
  #}}}
  # Usage example:{{{
  #
  #     $ git clone https://github.com/AndrewRadev/splitjoin.vim
  #     $ cd splitjoin.vim
  #     $ vim-read-plugin-help
  #     :help splitjoin
  #}}}
  vim +"set runtimepath+=$PWD|silent! helptags ALL"
}

# regular {{{2
# awk {{{3

alias rawk='rlwrap awk'

# iconv {{{3

# What's `iconv`?{{{
#
# A utility to convert a text from one encoding (-f ...) to another (-t ...).
#}}}
# What's `ascii//TRANSLIT`?{{{
#
# An encoding similar to `ascii`.
# The difference is that characters are transliterated when needed and possible.
#
# This means that when a character cannot be represented in the target character
# set, it should be approximated through one or several similar looking characters.
# Characters that cannot be transliterated are replaced with a question mark (?).
#}}}
alias iconv_no_accent='iconv -f utf8 -t ascii//TRANSLIT'

# iotop {{{3

# `iotop` monitors which process(es) access our disk to read/write it:
alias iotop='command iotop --only --processes'
#                            │      │
#                            │      └ no threads
#                            │
#                            └ only active processes
#
# NOTE: Install the `iotop-c` package; not the `iotop` package.
# Rationale: The `iotop` binary from the latter package needs to be run with sudo.
# The one from the former can be run as a non-root user:
#
#    > Running  iotop  as   non-root  user  is  possible  by   adding  the  NET_ADMIN
#    > capability. This can be done by e.g.:
#    >
#    > $ sudo setcap 'cap_net_admin+eip' <path-to>/iotop
#
# Source: https://www.mankier.com/8/iotop-c

# ip {{{3

alias ip='command ip --color=auto'

# man_ascii {{{3

alias man_ascii='man ascii | grep --after-context=20 Tables'
alias man_ascii_long='man ascii | grep --after-context=67 Oct | less'

# nethogs {{{3

# `nethogs` is a utility showing  which processes are consuming bandwidth on our
# network interface.
alias net_watch='nethogs enp3s0'

# tlmgr_gui {{{3

alias tlmgr_gui='
  tlmgr gui \
  -font "helvetica 20" \
  -geometry=1920x1080-0+0 \
  >/dev/null 2>&1 & && disown \
'

# what_is_my_ip {{{3

alias what_is_my_ip='curl --fail --location --show-error --silent ifconfig.me'

# Key Bindings {{{1
# How to bind a function to a key sequence using both the meta and control modifiers?{{{
#
# This is how you would do it for `M-C-z`:
#
#     bindkey '\e^z' your_function
#                 │
#                 └ replace 'z' with the key you want
#}}}
# How to set the position of the cursor in a key binding using the `-s` flag (`bindkey -s`)?{{{
#
# Write `\e123^B` at  the end of the RHS, to position  the cursor 123 characters
# before the end of the line.
#
# Example:
#
#     bindkey -s '^Xr' '^A^Kfor f in *; do echo mv \"$f\" \"$f\";done\e7^B'
#}}}

# Ctrl {{{2
# C-SPC      set-mark-command {{{3

bindkey '^ ' set-mark-command

# C-^        previous_directory {{{3
# cycle between current dir and old dir
function __previous_directory {
  # contrary to bash, zsh sets `$OLDPWD` immediately when we start a shell
  # so, no need to check it's not empty
  cd -
  # refresh the prompt so that it reflects the new working directory
  zle reset-prompt
}
zle -N __previous_directory
bindkey '^^' __previous_directory

# C-d        delete-char-or-list {{{3

# Purpose:{{{
#
# Don't  display all  possible shell  commands when  I press  `C-d` on  an empty
# command-line which only contains whitespace; just close the shell.
#
# Also, don't terminate the shell in a Vim popup terminal.
# It could lead to many issues; look for `IGNORE_EOF` in `~/.zshenv`.
#}}}
function __delete-char-or-list {
  # we're in a Vim terminal
  if [[ -n "$VIM_TERMINAL" ]]; then
    if [[ "$BUFFER" =~ '^\s*$' ]]; then
      :
    else
      zle delete-char-or-list
    fi
  # we're in a regular terminal
  elif [[ "$BUFFER" =~ '^\s+$' ]]; then
    exit
  else
    zle delete-char-or-list
  fi
}
zle -N __delete-char-or-list
bindkey '^D' __delete-char-or-list

# C-k        kill_line_or_region {{{3

function __kill_line_or_region {
  if (( $REGION_ACTIVE )); then
    zle kill-region
  else
    zle kill-line
  fi
}
zle -N __kill_line_or_region
bindkey '^K' __kill_line_or_region

# C-q        quote_word_or_region {{{3

# useful to quote a url which contains special characters
function __quote_word_or_region {
    if (( $REGION_ACTIVE )); then
      zle quote-region
    else
      # Alternative:{{{
      #
      #     RBUFFER+="'"
      #     zle vi-backward-blank-word
      #     LBUFFER+="'"
      #     zle vi-forward-blank-word
      #}}}
      zle set-mark-command
      zle vi-backward-blank-word
      zle quote-region
    fi
}
zle -N __quote_word_or_region
#    │
#    └ -N widget [ function ]
# Create a user-defined widget.  When the  new widget is invoked from within the
# editor, the specified shell function is called.
# If no function name is specified, it defaults to the same name as the widget.
bindkey '^Q' __quote_word_or_region

# C-x        (prefix) {{{3

# NOTE: It  seems  we  can't  bind  anything to  `C-x  C-c`,  because  `C-c`  is
# interpreted as an interrupt signal sent  to kill the foreground process.  Even
# if pressed after `C-x`.
#
# It's probably done  by the terminal driver.  Maybe we  could disable this with
# `stty` (the  output of  `stty -a` contains  `intr = ^C`),  but it  wouldn't be
# wise, because it's too important.
# We would need to find a way to disable it only after `C-x`.

# C-x C-?         __complete_debug {{{4

# What's the purpose of the `_complete_debug` widget?{{{
#
# It performs ordinary  completion, but captures in a temporary  file a trace of
# the shell commands executed by the completion system.
# Each completion attempt gets its own file.
# A command to view each of these files is pushed onto the editor buffer stack.
#}}}
# Why do you create a wrapper around the default widget `_complete_debug`?{{{
#
# After invoking the `_complete_debug` widget, you'll see sth like:
#
#     Trace output left in /tmp/zsh6028echo1 (up-history to view)
#                                             ^----------------^
# If you invoke  `up-history` (for us `C-p`  is bound to sth  similar because of
# `bindkey  -e`), in  theory zsh  should populate  the command  line with  a vim
# command to read the trace file.
# In practice, it won't happen because you've enabled 'MENU_COMPLETE'.
# Because of this, after pressing Tab, you've already entered the menu,
# and `C-p` will simply select the above match in the menu.
#
# MRE:
#
#     autoload -Uz compinit
#     compinit
#     setopt MENU_COMPLETE
#     bindkey '^X?' _complete_debug
#     bindkey '^P' up-history
#
# So, to conveniently read the trace  file, we make sure that 'MENU_COMPLETE' is
# temporarily reset.
#}}}
function __complete_debug {
  unsetopt MENU_COMPLETE
  zle _complete_debug
  # no need to restore the option, the change is local to the function
}
zle -N __complete_debug
bindkey '^X?' __complete_debug

# C-x C-d         end-of-list {{{4

# Purpose:{{{
#
# `end-of-list` lets you make a list of matches persistent.
#
#     $ echo $HO C-d
#         → parameter
#           HOME  HOST    # this list may be erased if you repress C-d later
#
#     $ echo $HO C-x C-d D
#         → parameter
#           HOME  HOST    # this list is printed forever
#     $ echo $HO          # new prompt automatically populated with the previous command
#}}}
bindkey '^X^D' end-of-list

# C-x C-e         edit-command-line {{{4

autoload -Uz edit-command-line
zle -N edit-command-line

# Why this wrapper function around the `vim(1)` command?{{{
#
# It lets us customize the environment.
#
# ATM, we simply add an autocmd to remove the leading dollar in front of a shell
# command, which  we often  paste when  we copy some  code from  the web  or our
# notes.
# We also remove a possible indentation in front of `EOF`.
# In the future, we could do more advanced things...
#}}}
# Why `$@`?{{{
#
# It's necessary for the temporary filename to be passed.
#}}}

#            ┌  `man zshparam /PARAMETERS USED BY THE SHELL`{{{
#            │
#            │ Run `stty sane` in order to set up the terminal before executing `vim`.
#            │ The effect of `stty sane` is local to the `vim` command, and is reset when Vim
#            │ finishes or is suspended.
#            │
#            ├───────┐}}}
__sane_vim() STTY=sane command vim +'autocmd TextChanged,InsertLeave <buffer> silent! call source#FixShellCmd()' "$@"

function sane-edit-command-line {
  # Do *not* replace `VISUAL` with `EDITOR`.{{{
  #
  # To  determine   which  editor   to  invoke,   `edit-command-line`  evaluates
  # `${VISUAL:-${EDITOR:-vi}}`:
  #
  #     /usr/share/zsh/functions/Zle/edit-command-line:20
  #
  # This gives the priority to `VISUAL` over `EDITOR`.
  # So, if you don't set `VISUAL` (only `EDITOR`), the latter will be used.
  # We've set it with the value `vim`, so `vim(1)` will be invoked.
  # But that's not what we want; we want `__sane_vim` to be invoked.
  #}}}
  local VISUAL='__sane_vim'
  zle edit-command-line
}
zle -N sane-edit-command-line

bindkey '^X^E' sane-edit-command-line
#              ^---^
#              wrapper function around the `edit-command-line()` function

# Meta {{{2
# M-[!$/@~]    _bash_complete-word {{{3

() {
  local key
  for key in '!' '$' '@' '/' '~'; do
    # What do these key bindings do? {{{
    #
    # They emulate what `M-!`, `M-$`, ..., `C-x !`, `C-x $`, ... do in bash.
    #
    # In bash, when  you press these keys,  you always end up  invoking the same
    # completion  function, which  seems  to inspect  the last  key  of the  key
    # binding which was pressed, to decide which kind of completion to use.
    #
    #     ! = command names
    #     $ = variable names
    #     / = filenames
    #     @ = host names
    #     ~ = user names (or named directories)
    #
    #     M- = opens the completion menu
    #     C-x = prints the list of matches
    # }}}
    # Do some of them shadow a builtin zsh command?{{{
    #
    # Yes.
    # By default, `M-!` is bound to `spell-word`.
    # And `M-$` to `history-expansion`.
    #
    # I don't care  about any of them, because  it seems that Tab is  able to do
    # the same:
    #
    #     % echoz Tab
    #         → echo
    #
    #     % !! !! !! Tab
    #         → last command, 3 times
    #}}}
    if [[ "$key" != '$' ]]; then
      bindkey "\e$key" _bash_complete-word
    fi
    bindkey "^X$key" _bash_list-choices
  done
}

# TODO: bash also provides `complete-in-braces`, bound by default to `M-{`.{{{
#
# Try  it in  bash; press  `M-AltGr-4` (not  `M-AltGr-x`, the  terminal wouldn't
# receive anything).
# It dumps on the command line a file pattern which can be expanded into all the
# filenames of  the current  directory whose  name matches  the text  before the
# cursor:
#
#     $ D M-{
#         → D{esktop,o{cuments,wnloads},ropbox}
#
# Unfortunately, it's not supported by `_bash_complete-word`.
# Try and find a way to re-implement it in zsh.
#}}}
# TODO: When we press `M-~`, our terminal doesn't receive anything. {{{
#
# This is a Xorg issue.
# For some reason, pressing `Alt AltGr key` doesn't work for some keys (i, u, x, ...).
# Run `xev-terse-terse`, then press `Alt AltGr`:
#
#     64 Alt_L˜
#     108 ISO_Level3_Shift˜
#
# Now press and release `a`:
#
#     24 bar˜
#
# Next press `i`: nothing happens.
# This is unexpected.  Why?
#
# Finally release `i`:
#
#     64 Alt_L˜
#     108 ISO_Level3_Shift˜
#
# This is also unexpected.  Why?
#
# Temporary Solution:
# Make another additional key generate `~`.
# This works because the issue doesn't apply to all physical keys, only these ones:
#
#    - F1, F2, F3, F5
#    - PgDown
#    - 1, 6, 8
#    - k_3, k_7, k_8 (`k_` = keypad)
#    - Tab, u, i, o
#    - Capslock, d, f, g, j
#    - greater/lower than sign, w, x, v, b
#
# ... out of around 98 (?) keys which can be combined with Meta + AltGr.
# Why those 25 keys?
# https://0x0.st/zpOa.txt
#
# Edit: If you go into the keyboard settings and choose the English layout (move
# it to the top), then repeat  the experiment with `xev(1)`, the issue persists,
# except this time, you'll see AltL and AltR:
#
#     (our custom layout)
#     64 Alt_L˜
#     108 ISO_Level3_Shift˜
#
#     (default english layout)
#     64 Alt_L˜
#     68 Alt_R˜
#
# Does this mean that the issue is in the kernel and not in Xorg?
# Not necessarily, it could simply be that our custom layout and the english one
# share the same “deficiencies”.
#
# Although, I can reproduce the issue in the console, where Xorg has no influence.
# So, I start thinking the issue is in the kernel...
#}}}

# M-#           pound-insert {{{3

bindkey '\e#' pound-insert

# M-,           copy-earlier-word {{{3

# Purpose:{{{
#
# `M-.` is useful to get the last argument of a previous command.
# But what if you want the last but one argument?
# Or the last but two.
#
# That's where the `copy-earlier-word` widget comes in.
#}}}
# usage:{{{
#
# Press `M-.` to insert the last argument of a previous command.
# Repeat until you reach the line of the history you're interested in.
#
# Then, press `M-,` to insert the last but one argument.
# Repeat to insert the last but two argument, etc.
#}}}
# How to cycle back to the last word of the command line?{{{
#
# Remove the inserted argument, and repeat the process:
#     `M-.` ...
#     `M-,` ...
#}}}
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey '\e,' copy-earlier-word

# M-;           insert-last-word-forward {{{3

# Purpose:{{{
#
# This key binding is  useful when you press `M-.` too many  times, and you want
# to go back to the next history event (instead of the previous one).
#
# https://unix.stackexchange.com/a/481714/289772
#}}}
# What does the `1` argument passed to `insert-last-word` mean?{{{
#
# From `man zshzle`:
#
#     When called from a shell function  invoked from a user-defined widget, the
#     command can take  one to three arguments.
#     The first argument specifies a  history offset which applies to successive
#     calls to this widget: if it is -1, the default behaviour is used, while if
#     it is 1, successive calls will move forward through the history.
#}}}
# Where is it documented that it is allowed to omit braces around a function's body?{{{
#
#     man zshmisc /COMPLEX COMMANDS/;/\Vword ... () [ term ] command
#}}}
insert-last-word-forward() zle insert-last-word 1
zle -N insert-last-word-forward
bindkey '\e;' insert-last-word-forward

# NOTE: To test the  influence of this key binding, uncomment  next key binding,
# and move it at the end of `~/.zshrc`:
#
#     bindkey "^R" history-incremental-search-backward
#
# It restores default `C-r`.
#
# Without the previous:
#
#     bindkey -M isearch " " self-insert
#
# ... as soon as you would type a  space in a search, you would leave the latter
# and go back to the regular command line.
