# Source: `~/.fzf/shell/key-bindings.fish`{{{
#
# If you ask `fzf(1)` to install its fish integration, it creates a symlink:
#
#     ~/.config/fish/functions/fzf_key_bindings.fish
#     →
#     ~/.fzf/shell/key-bindings.fish
#
# And it creates this file:
#
#     ~/.config/fish/functions/fish_user_key_bindings.fish
#
# With this contents:
#
#     function fish_user_key_bindings
#       fzf_key_bindings
#     end
#
# Source: https://github.com/junegunn/fzf/issues/851#issuecomment-281558260
#}}}
#   What would execute the function `fish_user_key_bindings`?{{{
#
# It's executed automatically on startup.
#
# From `man bind /DESCRIPTION/;/fish_user_key_bindings`:
#
#    > To save custom keybindings, put the bind statements  into  config.fish.
#    > Alternatively,  fish  also  automatically  executes  a  function called
#    > fish_user_key_bindings if it exists.
#
# From `man fish-interactive /CUSTOM BINDINGS/;/fish_user_key_bindings`:
#
#    > Put   bind   statements   into   config.fish   or   a  function  called
#    > fish_user_key_bindings.
#
# ---
#
# On startup, the variable `fish_key_bindings` is set:
#
#     $ set --show fish_key_bindings
#     $fish_key_bindings: set in universal scope, unexported, with 1 elements
#     $fish_key_bindings[1]: |fish_default_key_bindings|
#
# It's meant to  be assigned the name  of the function which has  to install the
# default key bindings.
# From `man fish-language /SHELL VARIABLES/;/Special variables/;/fish_key_bindings`:
#
#    > fish_key_bindings
#    >        the name of the function that sets up the keyboard shortcuts for
#    >        the command-line editor.
#
# When  it's set,  a `fish_key_bindings`  event is  emitted, which  the function
# `__fish_reload_key_bindings` listens to:
#
#     $ functions --handlers | grep fish_key_bindings
#     fish_key_bindings __fish_reload_key_bindings
#
#     $ type __fish_reload_key_bindings | head --lines=3
#     __fish_reload_key_bindings is a function with definition
#     # Defined interactively
#     function __fish_reload_key_bindings --description='...' --on-variable fish_key_bindings
#
# From `man function /DESCRIPTION/;/--on-variable`:
#
#    > • -v or --on-variable VARIABLE_NAME tells fish  to  run  this  function
#    >   when  the  variable VARIABLE_NAME changes value.
#
# The latter function calls `fish_user_key_bindings`:
#
#     $ type __fish_reload_key_bindings | tail --lines=5
#             if functions --query fish_user_key_bindings >/dev/null
#                 fish_user_key_bindings 2>/dev/null
#             end
#
#     end
#}}}

# Key Bindings {{{1

bind \cr fzf-history
bind \ej fzf-cd

# Variables {{{1
# `FZF_DEFAULT_COMMAND` and `FZF_DEFAULT_OPTS` are the only variables that `fzf(1)` expects you to export.{{{
#
# That  is, they  are the  only variables  which the  `fzf(1)` binary  reads via
# `os.Getenv()`.
#
# Other environment variables are documented (like `FZF_CTRL_T_COMMAND`):
# https://github.com/junegunn/fzf#environment-variables
# But  they're only  used in  the  shell integration  layer; not  by the  binary
# itself.
#}}}

# `FZF_DEFAULT_COMMAND` {{{2

set --export FZF_DEFAULT_COMMAND 'find . -mindepth 1 -printf "%P\n" 2>/dev/null'

# `FZF_DEFAULT_OPTS` {{{2
# `FZF_PROMPT` {{{3

# We need  to export this to  enforce a consistent  end for our prompt,  when we
# want to  tweak it  to include  some arbitrary info.   We rely  on this  end to
# implement some missing readline key bindings.
set --export FZF_PROMPT '≻ '

# `FZF_UNDOFILE` {{{3

# We should  save one undo  history per  `fzf(1)` process (i.e.  include `$PPID`
# somewhere in `$FZF_UNDOFILE`).   But I'm not sure how  to automatically remove
# that file  once the  `fzf(1)` process  terminates.  For now,  we use  a single
# `$FZF_UNDOFILE` which  we remove whenever  a new `fzf(1)` process  is started.
# This means that if you start several `fzf(1)` processes, only the last one has
# an undo history.  I guess that should be fine; we probably rarely run multiple
# `fzf(1)` processes simultaneously.
set --export FZF_UNDOFILE $TMPDIR/fzf/readline-undo
#   ^------^
# For `$HOME/bin/util/fzf-readline/undo` to be able to read the variable.

set --local keys ctrl-d \
    ctrl-h \
    ctrl-k \
    ctrl-t \
    ctrl-u \
    ctrl-w \
    ctrl-y \
    alt-d \
    alt-q \
    alt-t \
    alt-u \
    alt-o \
    alt-i

set --local actions delete-char \
    backward-delete-char \
    kill-line \
    'transform-query($HOME/bin/util/fzf-readline/transpose-chars {q})' \
    unix-line-discard \
    backward-kill-word \
    yank \
    kill-word \
    replace-query \
    'transform-query($HOME/bin/util/fzf-readline/transpose-words {q})' \
    'transform-query($HOME/bin/util/fzf-readline/change-case {q} up)' \
    'transform-query($HOME/bin/util/fzf-readline/change-case {q} down)' \
    'transform-query($HOME/bin/util/fzf-readline/change-case {q} capital)'

set --local undo_save_key_bindings
for key in $keys
    if set index $(contains --index -- $key $keys)
        set --append undo_save_key_bindings \
            '--bind="'$key':execute-silent($HOME/bin/util/fzf-readline/undo {q} save)+'$actions[$index]'"'
    end
end

# `--history` {{{3
# Make `alt-n`/`alt-p` cycle through past queries.

set --local history_file $HOME/.local/share/fzf/history
set --local history_dir $(string replace --regex '/[^/]*$' '' $history_file)
if ! test -d "$history_dir"
    mkdir -p -- $history_dir
end

# `--history` causes `ctrl-n`/`ctrl-p`  to be re-bound to `next-history`/`prev-history`.
# We don't want that.  We prefer `ctrl-n`/`ctrl-p` to remain bound to `down`/`up`.
# Instead, we bind `next-history`/`prev-history` to `alt-n`/`alt-p`.
set --local history_opts "--history=$history_file" \
    '--bind=ctrl-n:down' \
    '--bind=ctrl-p:up' \
    '--bind=alt-n:next-history' \
    '--bind=alt-p:prev-history' \

# `--preview` {{{3

# About `tree(1)`:{{{
#
# `-C`  turns colorization on.
# `-F` appends a `/` for directories, a `*` for executable file, ...
# `-a` prints hidden files.
#
# `-v`  sorts by  version which  feels  more natural  to people,  when the  text
# contains a mixture of letters and digits.  See:
# https://www.gnu.org/software/coreutils/manual/html_node/Version-sort-overview.html
#
# `-L 10` prevents the display of directories whose depth is greater than 10.
# `--filelimit 300` prevents `tree(1)` from  descending directories that contain
# more than 300 entries.
#}}}
set --local TOO_BIG $(math '5*1024*1024')
#           ^-----^
#           uppercase to remind us that it's configurable
#           (i.e. the current value is arbitrary)

# `bat(1)`'s `--line-range` option restricts the load times for long files.
set --local preview '
    if [[ -f {} ]]; then
        if (( $(stat --format=%s -- {}) > '$TOO_BIG' )); then
            echo {}
            echo
            echo ''the file is too big to be previewed''

        elif [[ {} =~ \.(epub|gz|pdf)$ ]]; then
            less -- {}

        else
            bat --line-range=1:500 --color=always --style=plain -- {}
        fi

    elif [[ -d {} ]]; then
        tree -C -F -a -v --dirsfirst --noreport -L 10 --filelimit=300 -- {}

    else
        echo {} | fold --spaces
    fi
'

# final `set --export` {{{3
# Do *not* separate options with newlines!{{{
#
#     ✘
#     set --export FZF_DEFAULT_OPTS '
#         --border=rounded
#         --cycle
#         ...
#     '
#
#     ✔
#     set --export FZF_DEFAULT_OPTS \
#         '--border=rounded' \
#         '--cycle' \
#         ...
#
# The first version would break `fzf#run()`.
# Although, that could be fixed with this patch:
#
#     diff --git a/plugin/fzf.vim b/plugin/fzf.vim
#     index f192ecb..07fb41c 100644
#     --- a/plugin/fzf.vim
#     +++ b/plugin/fzf.vim
#     @@ -512,7 +512,7 @@ try
#          let optstr .= ' --height='.height
#        endif
#        " Respect --border option given in $FZF_DEFAULT_OPTS and 'options'
#     -  let optstr = join([s:border_opt(get(dict, 'window', 0)), $FZF_DEFAULT_OPTS, optstr])
#     +  let optstr = join([s:border_opt(get(dict, 'window', 0)), $FZF_DEFAULT_OPTS, optstr])->tr("\n", ' ')
#        let prev_default_command = $FZF_DEFAULT_COMMAND
#        if len(source_command)
#          let $FZF_DEFAULT_COMMAND = source_command
#
# But that would require we create a PR, and there is no guarantee that it would
# be accepted.  Besides, newlines look weird  here and might cause other issues;
# don't bother.  They're still OK in the value of `--preview`.
#}}}

# `--ansi`: enable processing of ANSI color codes
# `--border=rounded`: draw a border around the window
# `--cycle`: wrap around the edges when selecting next/previous match (opposite = `--no-cycle`)
# `--exact`: disable fuzzy matching; enforce literal matching
# `--height`: specify the height of the fzf window{{{
#
# We want 10 lines for the matches.
# But we need to add 3: 2 for the top and bottom borders, and 1 for the prompt.
#}}}
# `--info="inline: ≺ "`: prepend `≺ ` to the finder info and join it to the query prompt{{{
#
#     ≻ query
#       12/345
#
#     →
#
#     ≻ query ≺ 12/345
#}}}
# `--layout=reverse`: reverse the order; move the query prompt next to the shell prompt{{{
# `--bind=...`
#
# `--bind` expects a comma-separated  list of `KEY:ACTION` and/or `EVENT:ACTION`
# binding expressions.  See `man fzf /KEY/EVENT BINDINGS`.
#
# Each expression lets you bind a key or an event to one or more actions.
#
# ---
#
# `ctrl-z:ignore`: don't suspend `fzf(1)` if we press `C-z` accidentally.
#
# ---
#
# `change:first`:  automatically move  to  the first  match  whenever the  query
# string is changed.  See:
#
#    - `man fzf /KEY/EVENT BINDINGS/;/AVAILABLE EVENTS:/;/change`
#    - `man fzf /KEY/EVENT BINDINGS/;/AVAILABLE ACTIONS:/;/first`
#
# ---
#
# `alt-j:preview-page-up`, `alt-k:preview-page-down`:
# scroll up/down whenever `M-j`/`M-k` is pressed.
#}}}
# `--scroll-off=1`: keep 1 line above/below when scrolling to the top/ bottom
# `--hscroll-off=1000`: center the matched substring
# `--preview`: execute the given command for the current line and display the result on the preview window.{{{
#
# `{}`  in the  command is  a  placeholder that  will be  replaced with  the
# single-quoted string of each line in the output of `fzf(1)`.
# See: `man fzf /OPTIONS/;/Preview/;/--preview`
#}}}
# `--preview-window=border-left,wrap,hidden`: set layout of preview window{{{
#
# `border-left` only draws the left-side border of the window.
#
# `wrap` wraps long lines; by default, they are truncated.
#
# `hidden` hides the window by default.
# You can still show it using the `toggle-preview` action.
#}}}
# `--color`: choose colors which are readable on a light background.{{{
#
# We use the “Paper color” color scheme:
# https://github.com/junegunn/fzf/wiki/Color-schemes#paper-color
#
# Here is the list of keys that we set, and their meaning:
#
#    - `fg`: Text (`..` in first column; only displayed when the actual text can't be displayed)
#    - `fg+`: Text
#    - `bg`: Background (whole window)
#    - `bg+`: Background
#    - `hl`: Highlighted substrings (in the first and second columns)
#    - `hl+`: Highlighted substrings
#    - `gutter`: Gutter on the left (defaults to `bg+`)
#    - `header`: Header (only visible if `--header` was passed to `fzf(1)`)
#    - `info`: Info (finder info; e.g. `12/34 (5)`)
#    - `marker`: Multi-select marker
#    - `pointer`: Pointer to the current line
#    - `prompt`: Prompt
#    - `spinner`: Streaming input indicator
#
# The `..+`  keys have  the same  meaning as their  counterpart without  the `+`
# suffix, with one difference: their scope is limited to the current line.
#
# `-1` is a special value which stands for the terminal default
# foreground/background color.
#
# https://github.com/junegunn/fzf/wiki/Color-schemes#color-configuration
#}}}
# Warning: Do *not* use `--filepath-word`.{{{
#
# It's meant  to make the cursor  jump/operate up to the  nearest path separator
# (i.e. slash), but it also breaks `C-w`, `M-d`, `M-b`, and `M-f`.
#}}}
# Warning: Do *not* change the separators used to surround the query in `--prompt` and `--info`.{{{
#
# We want them to be special (i.e. not practical to type interactively).
# We rely on them to implement some readline key bindings (e.g. `C-t`).
# *Unless* you refactor your config files (`:ConfigGrep [≺≻]`)...
#}}}
set --export FZF_DEFAULT_OPTS \
    '--ansi' \
    '--border=rounded' \
    '--cycle' \
    '--ellipsis="…"' \
    '--exact' \
    '--height=15' \
    $history_opts \
    '--hscroll-off=1000' \
    '--info="inline: ≺ "' \
    '--layout=reverse' \
    "--preview='$preview'" \
    '--preview-window=border-left,wrap,hidden' \
    "--prompt='$FZF_PROMPT'" \
    '--scroll-off=1' \
    $undo_save_key_bindings \
    '--bind="start:execute-silent(rm $FZF_UNDOFILE)"' \
    '--bind=change:first' \
    '--bind=btab:up' \
    '--bind=tab:down' \
    '--bind="ctrl-_:transform-query($HOME/bin/util/fzf-readline/undo {q} restore)"' \
    '--bind=ctrl-g:print-query' \
    '--bind=ctrl-x:toggle+down' \
    '--bind=ctrl-z:ignore' \
    '--bind=alt-a:toggle-all' \
    '--bind=alt-j:preview-half-page-down' \
    '--bind=alt-k:preview-half-page-up' \
    '--bind=alt-w:toggle-preview' \
    '--bind="alt-W:change-preview-window(75%,nohidden|nohidden)"' \
    '--color=fg:#4d4d4c' \
    '--color=fg+:#4d4d4c' \
    '--color=bg:-1' \
    '--color=bg+:#e8e8e8' \
    '--color=hl:#d7005f' \
    '--color=hl+:#d7005f' \
    '--color=gutter:-1' \
    '--color=header:#4271ae' \
    '--color=info:#4271ae' \
    '--color=marker:#4271ae' \
    '--color=pointer:#d7005f' \
    '--color=prompt:#8959a8' \
    '--color=spinner:#4271ae'
# }}}1
# Interface {{{1
function fzf-cd #{{{2
    # Fuzzy search directory below given directory, to `cd` into.

    set -f starting_point $(commandline --current-token)
    # expand possible special characters like `~`, `$HOME`, ...
    if ! _commandline_has_unbalanced_quotes
        eval set -f starting_point $starting_point
    end

    if test -z "$starting_point"
        # default to current directory
        set -f starting_point '.'
    end

    # From `man tree`:{{{
    #
    #    - `-C`: turn colorization on
    #    - `-L 2`: maximum depth of 2
    #    - `-x`: stay on the current file-system only
    #    - `--dirsfirst`: list directories before files
    #    - `--noreport`: don't print file and directory report at the end of the tree listing
    #}}}
    find -- $starting_point -mindepth 1 -type d 2>/dev/null \
        | fzf --preview='tree -C -L 2 -x --dirsfirst --noreport {}' --scheme=path \
        | read -f choice
    commandline --function repaint

    if test -n "$choice"
        cd -- $choice
        frec --add $choice
        commandline --replace --current-token ''
        commandline --insert --current-token -- $prefix
    end
end

function fzf-history #{{{2
    # Fuzzy search command history.

    # Careful: The entries must always be separated with NULLs.{{{
    #
    # To support past  commands which were split on multiple  lines.  Because of
    # those,  there is  no  guarantee  that a  newline  separates 2  consecutive
    # entries.  It  might as  well separate  2 consecutive  lines from  the same
    # entry.  IOW, a newline is ambiguous; but not a NULL.
    #}}}
    # Quoting the fzf query is necessary in case the current command-line is not empty and split on multiple lines.{{{
    #
    #     --query="$(...)"
    #             ^      ^
    #
    # Otherwise:
    #
    #     $ printf 'a
    #     b'
    #
    #     # press: C-p (to call back previous executed command)
    #     # press: C-r (to fuzzy search through the history using the current command-line as a query)
    #     # expected: the used query is:  printf 'a b'
    #     # actual: the used query is:  b'
    #
    # That's  because,   without  the   quotes,  fish   splits  the   output  of
    # `commandline` on the newline, which gives 2 elements:
    #
    #     printf 'a
    #     b'
    #
    # Then, fish  expands the cartesian  product between these elements  and the
    # string `--query`, which gives:
    #
    #     --query=printf 'a --query=b'
    #
    # Obviously, that's wrong.  This would be better:
    #
    #     --query='a b'
    #}}}
    #   Also, the `=` assignment is only necessary if you remove the quotes.{{{
    #
    #     --query="$(...)"
    #            ^
    #
    #     # press: C-p (to call back previous executed command)
    #     # press: C-r (to fuzzy search through the history using the current command-line as a query)
    #     # expected: fzf starts
    #     # actual: - fzf doesn't start
    #               - an error is briefly printed (“unknown option: b'”)
    #               - an extra ruler is printed (which probably erases the previous error message)
    #}}}
    # About `--print0`:{{{
    #
    # Without, fzf would append an undesirable trailing newline.
    # We don't  want it  to be  inserted, so  we would  need to  trim it,  or to
    # include `string collect` in the pipeline.
    #}}}
    # About `--tiebreak=index`:{{{
    #
    # When the  scores of  2 lines  are tied,  give priority  to the  line which
    # appeared earlier in the input stream.
    #
    # This option  makes sense when  the entries from  the source are  sorted in
    # chronological order (which  is the case here).  You want  to preserve that
    # order, because  the entry you're  looking for  is probably among  the most
    # recent ones (not among the shortest ones).
    #}}}
    if history --null \
      | fzf --preview-window=bottom,2,border,wrap,nohidden \
        --preview='echo {} | fish_indent --ansi' \
        --print0 \
        --query=$(commandline --current-buffer) \
        --read0 \
        --scheme=history \
        --tiebreak=index \
      | read -f --null choice
        commandline --replace -- $choice
    end
    # Repaint no matter what.
    # In particular,  repaint even  if we  typed a new  command absent  from the
    # history, causing the previous test to fail.
    commandline --function repaint
end
#}}}1
