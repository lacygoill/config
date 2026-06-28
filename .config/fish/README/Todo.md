# Integration
## fzf

<https://github.com/PatrickF1/fzf.fish>

## vim-fish

<https://github.com/dag/vim-fish>

Check whether there is something interesting in there.
If you find something, integrate the code into our own Vim plugin (fish-shell).

##
# Features
## implement a "super menu" ala gotbletu to fuzzy search everything

- <https://www.youtube.com/watch?v=8SqakfCSzQk>
- <https://github.com/gotbletu/shownotes/tree/master/fzf_nova>

- <https://www.youtube.com/watch?v=41JxYe70Xwo>
- <https://github.com/gotbletu/shownotes/tree/master/fzf_speed>

---

What would go into this super menu?

   - clipboard history
   - ebooks
   - Firefox history
   - fish key bindings
   - line from config files
   - locate (or `frec -l`?)

See also: <https://github.com/zsh-users/zaw#sources>

In the fzf  menu, install a key  binding (or several) to do  something else with
the selected entry/ies (e.g. just output the entry, use a different program...).

---

For bookmarks, extract URLs from `~/Wiki/warez/warez.md`.
Are there other files from which we should extract URLs?

---

For Firefox history, here is a starting point:

    #!/bin/bash -

    # shellcheck disable=SC2155
    readonly FIREFOX_HISTORY="$(find "$HOME/.mozilla/firefox/" -name 'places.sqlite')"
    if ! [[ -f "$FIREFOX_HISTORY" ]]; then
      exit 1
    fi

    tmp_file="$(mktemp)"
    cp "$FIREFOX_HISTORY" "$tmp_file"
    sqlite3 "$tmp_file" 'SELECT url, title FROM moz_places WHERE visit_count > 0' \
      | fzf \
      | awk -F'|' '{ print $1 }' \
      | xargs --delimiter='\n' xdg-open

    rm -- "$tmp_file"

---

For the clipboard history, we had this function in our zshrc:

    function fzf-clipboard() {
      # TODO: Find a clipboard manager which you can configure to ignore some apps.
      # Greenclip doesn't allow  you to do that  (you can but, for  some reason, its
      # configuration is reset whenever you copy some text).
      #
      # See: https://wiki.archlinux.org/index.php/Clipboard#Managers
      # (clipster seems the least bad...)
      #
      # fuzzy find clipboard history
      #
      #     xsel -ib <<<"$(greenclip print | fzf)"
    }

Do we really need a clipboard manager?

---

Could/Should we use a kitten plugin?
A tmux popup?

## install a key binding letting us execute *any* bash command

We already support  bash heredocs, here-strings, and  process substitutions, but
that's not enough.  There are constructs which are harder to reliably detect.

However, we could install a key binding which would give us support *on-demand*:

    $ my bash command
    # press some key
    $ bash /path/to/some/script.bash
           ^-----------------------^
           should contain the old command-line
           (and maybe a `$ bat --language=bash --style=plain` command)

For inspiration:

    ~/.config/fish/functions/my-execute.fish
    /_execute_bash_syntax

## restore the ability to start a function as a background job

Using this autoload function:

    function bgFunc
      fish -c $(string join -- ' ' $(string escape -- $argv)) &
    end

Source: <https://github.com/fish-shell/fish-shell/issues/238#issuecomment-1015806466>

##
# Documentation
## read these man pages

    :Man fish(1)
    # 110 lines

    :Man fish-completions(1)
    # 195 lines

    :Man fish-faq(1)
    # 449 lines

    :Man bind(1)
    # 454 lines

    :Man fish-for-bash-users(1)
    # 480 lines

    :Man fish-tutorial(1)
    # 749 lines

    :Man fish-interactive(1)
    # 785 lines

    :Man fish-language(1)
    # 2115 lines

That's 5337 lines to read.

---

Also, quickly look at the description of all these man pages:

    $__fish_data_dir/man/man1/

If any  one of them  seems useful right  now (to implement  a feature or  fix an
issue), read its relevant paragraphs.

For example, the `history` command seems useful.

##
## document why we use `$()` for command substitutions instead of `()`

Rationale: <https://github.com/fish-shell/fish-shell/issues/159>

Also, it's less ambiguous.

## document when we should pass `--quiet` to `string match`

After working on the `my-complete` function, it seems almost always necessary to
avoid  weird glitches  (like a  prompt being  printed which  didn't execute  any
command, or some autocompletion suffix which is not correctly cleared).

However, it seems useless in a command substitution assigned to a variable.

    set -f var $(string match ...)

## document that trailing newlines are trimmed in `"$(cmd)"`

    $ printf "$(printf 'x\n\n\n')" | xxd
    00000000: 78                                       x˜

From `man string-collect`:

   > Any  trailing  newlines on the input are trimmed, just as with "$(cmd)"
   > substitution.

Is it documented in a better place?

---

They seem to be also trimmed if we drop the double quotes:

    $ printf $(printf 'x\n\n\n') | xxd
    00000000: 78                                       x˜

However, there is a difference if you assign the command substitution to a variable:

    $ set var $(printf 'x\n\n\n'); set --show var
    $var[1]: |x|˜
    $var[2]: ||˜
    $var[3]: ||˜

    $ set var "$(printf 'x\n\n\n')"; set --show var
    $var[1]: |x|˜

## document that `$(cmd | string collect)` is mostly equivalent to `"$(cmd)"`

    $ echo ,$(echo one\ntwo\nthree),
    ,one, ,two, ,three,˜

    $ echo ,"$(echo one\ntwo\nthree)",
    ,one˜
    two˜
    three,˜

    $ echo ,$(echo one\ntwo\nthree | string collect),
    ,one˜
    two˜
    three,˜

## document that `string` commands append a trailing newline, unless their input is connected to a pipe

    $ string trim 'x' | xxd
    00000000: 780a                                     x.
                ^^

    $ printf 'x' | string trim | xxd
    00000000: 78                                       x

Why?
Is that true for all subcommands?

##
# Miscellaneous
## use `argparse(1)` to make function code easier to read

## review all TODOs in all our fish files

    :vimgrep /TODO\|FIXME/gj ~/.config/fish/**/*.fish

## review the utility functions in there `$HOME/.local/share/fish/functions`

Some of them could be useful to write more powerful completions.

## use bash utilities in fish shell

<https://github.com/edc/bass>

## compile all fish-html files into an epub

    $ pandoc $HOME/.local/share/doc/fish/*.html $HOME/.local/share/doc/fish/cmds/*.html \
          --output=$TMPDIR/fish_shell.epub \
          --standalone \
          --css $HOME/.local/share/doc/fish/_static/basic.css \
          --css $HOME/.local/share/doc/fish/_static/classic.css \
          --css $HOME/.local/share/doc/fish/_static/default.css \
          --css $HOME/.local/share/doc/fish/_static/pydoctheme.css \
          --css $HOME/.local/share/doc/fish/_static/pygments.css \
          --toc --toc-depth=1 \
          --metadata title='Fish Documentation'

The previous command gives warnings:

    [WARNING] Could not fetch resource '../_static/fish.png': PandocResourceNotFound "../_static/fish.png"

You can suppress most of them by being in the root directory:

    $ cd $HOME/.local/share/doc/fish/
    $ pandoc $HOME/.local/share/doc/fish/*.html \
        --output=$TMPDIR/fish_shell.epub \
        --standalone \
        --css $HOME/.local/share/doc/fish/_static/basic.css \
        --css $HOME/.local/share/doc/fish/_static/classic.css \
        --css $HOME/.local/share/doc/fish/_static/default.css \
        --css $HOME/.local/share/doc/fish/_static/pydoctheme.css \
        --css $HOME/.local/share/doc/fish/_static/pygments.css \
        --toc --toc-depth=1 \
        --metadata title='Fish Documentation'

But notice that we've removed the html files under the `cmds/` subdirectory.
Otherwise, the same warning is still given many times.
The issue is that the html files are in 2 different directories.

Could these links help?
- <https://pandoc.org/MANUAL.html#epubs>
- <https://pandoc.org/epub.html>

---

Edit: This works:

    $ cp -R $HOME/.local/share/doc/fish $HOME/.local/share/doc/fish/cmds .

    $ vim
    :args **/*.html
    :silent argdo :% substitute:\%(\.\./\|\<\)_static/fish\.png:$HOME/.local/share/doc/fish/_static/fish.png:ge
    :silent argdo update
    :quitall!

    $ pandoc ./fish/*.html ./fish/cmds/*.html \
              --output=$TMPDIR/fish_shell.epub \
              --standalone \
              --css=./fish/_static/basic.css \
              --css=./fish/_static/classic.css \
              --css=./fish/_static/default.css \
              --css=./fish/_static/pydoctheme.css \
              --css=./fish/_static/pygments.css \
              --toc --toc-depth=1 \
              --metadata title='Fish Documentation'

Now try to build a better index (the one displayed when we press Tab).

Edit: Actually, when opening the ebook I found some image which failed to be open.
Maybe we need to do more substitutions.
In any case, this would be  an interesting exercise to better understand pandoc,
but it's not that important for fish.
Move this todo item in a pandoc note.

## should we install key bindings to interact with selection?

In the past, we used these:

    bind \em begin-selection
    bind \ek kill-selection end-selection

But we  accidentally press  `M-m` too  often, which  is distracting,  because it
causes the newly inserted text to be highlighted with an unexpected color.

When that happened, we  had to kill the selection (`M-k`),  then undo the change
(`C-_`), which was too annoying.
