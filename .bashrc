# How to restore the file to its default contents?{{{
#
#     :%d_
#     :0r /etc/skel/.bashrc
#}}}
# Where can I find some completion functions or script examples?{{{
#
#     /usr/share/doc/bash/examples/
#
# If the directory does not exist, install the package `bash-doc`.
#}}}

# TODO: review this file:
#
#     • can we delete things?
#     • is everything fully understood/explained?

# TODO: review ~/.inputrc

# TODO:
#
# `blink-matching-paren` is a (recent) bash option, which I set in `~/.inputrc`.
# Suppose I forget from which man page it comes from.
# How to look for it in all man pages?
# This doesn't work:
#
#     man -s1 -Kw blink-matching-paren
#     man -Kw --regex 'blink*matching*paren'
#
# It seems we don't know how to search some text containing a dash.
#
# Update:
# In fact, the issue is more complex:
#
#     man -Kw --regex 'the following is a'
#
# The output contains the page for bash (which does NOT match the regex),
# but NOT the terminfo page (which DOES match the regex).



# If not running interactively, don't do anything
# Why don't you use the single line `[[ $- = *i* ]] || return` (shorter)?{{{
#
#     1. It's not posix-compliant.
#     2. The `case` syntax seems more powerful.
#}}}
case "$-" in
  *i*) ;;
  *) return ;;
esac

# set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

# Environment Variables {{{1

#                                   ┌─ don't save commands beginning with a space
#                                   │
#                   ┌─ ignoredups + ignorespace
#                   │
export HISTCONTROL="ignoreboth:erasedups"
#                              │
#                              └─ erase duplicate lines in the history

#                                  ┌─ ignore commands containing only 2 characters
#                                  │
export HISTIGNORE="clear:history:?:??"
#                                │
#                                └─ ignore commands containing only 1 character

# ---------------------
# Eternal bash history.
# ---------------------
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login

# Why don't we write `~` instead of `${HOME}`?
# Because whenever we execute a command, the `history` builtin is executed to
# merge the history of all terminals. We've configured this merge with `PROMPT_COMMAND`.
# And it seems that `history` can't expand the tilde.
#
# If we use a tilde in the path to the history file and quotes around it
# (single or double), the latter prevent the expansion of the tilde.
#
# Conclusion:
# NEVER use `~` inside an assignment, because the only special characters inside
# quotes are:  $ ` \ @
#
# We could get around this issue with one of the following:
#   export HISTFILE=~/.bash_eternal_history      ✘ works but not protecting the
#                                                  value is a bad habit
#   export HISTFILE=~/".bash_eternal_history"    ✘ ugly
#
# Fore more info:
# https://unix.stackexchange.com/a/151865/232487

export HISTFILE="${HOME}/.bash_eternal_history"

# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "

# merge the history of all terminals

# the value of `PROMPT_COMMAND` is executed as a command prior to issuing each
# primary prompt; for more info about `history`:
# `man bash`  section “shell builtin commands“
export PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND}"
#                     │         │           │           │{{{
#                     │         │           │           └ Read the contents of the history file
#                     │         │           │             and append them to the current history list
#                     │         │           │
#                     │         │           └ Clear the history list by deleting all the entries
#                     │         │
#                     │         └ Append the history list to the history file
#                     │           history list = history lines entered since the beginning
#                     │                          of the current bash session (kind of temporary buffer)
#                     │
#                     └ double quotes to allow the expansion of `${PROMPT_COMMAND}`
#}}}

# Options {{{1

# Typing a directory name alone is enough to cd into it
shopt -s autocd

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
# Used by the `select` command to determine the column length and the terminal
# width when printing selection lists.
shopt -s checkwinsize

# don't allow a `>` redirection to overwrite the contents of an existing file
# use `>|` to override the option
set -o noclobber

# Enable the pattern `**` to match match all files and zero or more directories
# and subdirectories. `**/` matches any path to a folder.
shopt -s globstar

# append to the history file, don't overwrite it
shopt -s histappend

# After a failed history expansion (e.g.: !<too big number>), don't give me an
# empty prompt. Reload it (unexpanded) into the readline editing buffer for
# correction.
shopt -s histreedit

# After a history expansion, don't execute the resulting command immediately.
# Instead,  write the expanded command into the readline editing  buffer for
# further modification.
shopt -s histverify

# Sourcing {{{1

# Warning: Don't move `Sourcing` after `Key bindings`!{{{
#
# It would give  priority to the key bindings defined  in third-party files over
# ours.
#}}}
. /usr/share/bash-completion/bash_completion

# Key bindings {{{1
# CTRL {{{2
# C-SPC        magic-space {{{3

# automatic history expansion (`!!`) when inserting a space
# WARNING:
# don't write this in `~/.inputrc`, it would prevent us from inserting spaces
# inside various programs (python, rlwrap) …
bind '" ": magic-space'

# C-r C-h  {{{3

# The default key binding to search in the history of commands is `C-r`.
# Remove it, and re-bind the function to `C-r C-h`.
bind -r "\C-r"
# Why?{{{
#
# On Vim's command-line, we can't use `C-r`, nor `C-r C-r`.
# So, we use `C-r C-h`.
# To stay consistent, we do the same in the shell.
#
# Besides, we can now use `C-r` as a prefix for various key bindings.
#}}}
# How did you find the original {rhs} in this key binding?{{{
#
# Start a bash shell without removing the `C-r` key binding,
# and execute:
#     $ bind -s | vipe
#     /fzf
#}}}
bind '"\C-r\C-h": " \C-e\C-u\C-y\ey\C-u`__fzf_history__`\e\C-e\er\e^"'

# C-x C-f/F    character-search {{{3

bind '"\C-x\C-f":  character-search'
bind '"\C-x\C-F":  character-search-backward'

# C-x C-r      resource-bashrc {{{3

# TODO:
# using non producable keycodes as lhs in intermediate key bindings is tricky;
# but which keycodes are usable? (keycode space)
bind    '"\e[99i~": re-read-init-file'
bind -x '"\e[99b~": reread'
#     │
#     └─ the rhs must processed as a shell command (like `fzf-file-widget`),
#        not a line edition command (like `\C-e | vim -R -\C-m`)
bind    '"\C-x\C-r":   "\e[99i~\e[99b~"'

# FIXME:
# ┌─ The name of the function must have a specific length:
# │          https://unix.stackexchange.com/q/370463/232487
# │
# │  yeah, I know, it's a weird bug ...
reread() {
  . "${HOME}/.bashrc" </dev/null 2>/dev/null
}

# C-x C-s      reexecute-with-sudo {{{3

# re-execute last command with `sudo`
bind '"\C-x\C-s": "sudo -E PATH= $PATH bash -c \"!!\" \C-m"'

bind -x '"\C-x\C-t": fzf-file-widget'
#     │
#     └── when `fzf-file-widget` is executed, the shell sets the READLINE_LINE
#         variable to the contents of the line buffer and the READLINE_POINT
#         variable to the current location of the insertion point
#
#         if `fzf-file-widget` changes the values of these variables, it will be
#         reflected in the editing state
#
#         without this flag, `fzf-file-widget` doesn't work, which means that it
#         probably relies on these 2 variables
#         `-x` sets them and make sure that readline takes into account the
#         change in their values

# FIXME:
# I don't really understand the `-x` option.
# According to what I wrote earlier, I should use `-x` in the next key binding.
# But if I do it gives the error:
#         transpose-chars: command not found
# What's the difference between `transpose-chars` and `fzf-file-widget`?
# Why do I need `-x` in one case, but not the other?
bind '"\C-t": transpose-chars'

# C-x C-v: read output of command inside Vim
bind '"\C-x\C-v": "\C-e | vim -R --not-a-term -\C-m"'

# C-x c        snippet-compare {{{3

bind '"\C-xc": "\C-a\C-kvimdiff <() <()\e5\C-b"'

# C-x r        snippet-rename {{{3

bind '"\C-xr": "\C-a\C-kfor f in *; do mv \"$f\" \"${f}\";done\e7\C-b"'
#          │
#          └ Rename

# META {{{2
# M-m       display man for the current command {{{3

bind '"\em": "\C-aman \ef\C-k\C-m"'
#             │   │   │  │
#             │   │   │  └─ kill everything after, up to the end of the line
#             │   │   └─ move 1 word forward
#             │   └─ type `man `
#             └─ go to beginning of line

# M-z       previous directory {{{3

# FIXME: how to refresh the prompt?
previous_directory() {
  # check that `$OLDPWD` is set otherwise we get an error
  [[ -z "${OLDPWD}" ]] && return
  cd -
}
bind -x '"\ez": previous_directory'

# M-Z       fuzzy-select-output {{{3

# insert an entry from the output of the previous command,
# selecting it with fuzzy search
bind '"\eZ": "$(!!|fzf)"'

# CTRL-META {{{2
# C-M-b     execute the current command line silently {{{3

# NOTE:
# In emacs, we write `C-M-b`, but if we hit this key in the terminal (after
# executing `cat`), we see that the latter receives `Escape` + `C-b`.
# So, in our next key binding, the `lhs` must be `\e\C-b`, and not `\C-\eb`.
#
#           ┌─ Black hole
#           │
# bind '"\e\C-b":  "\C-e >/dev/null 2>&1 &\C-m"'
#                                      │
#                                      └─ execute in the background

# Update:
# I've commented the key binding because I hit it by accident too often.
# It happens when I press Escape then C-b quickly afterwards.

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
