set -f expanded_abbreviation $(
    # `string-unescape(1)` is necessary for some abbreviations.{{{
    #
    # Such as:
    #
    #     abbr --add ssud --set-cursor=% " s --provider=urbandictionary '%'"
    #
    # Because they're printed like this in the output of `$ abbr --show`:
    #
    #     abbr -a --set-cursor='%' -- ssud \ s\ --provider=urbandictionary\ \'\%\'
    #}}}
    # We delete lines starting with `#` to handle abbreviations with a trailing comment.{{{
    #
    # Example:
    #
    #     abbr --add foo 'some command
    #         # some
    #         # multiline
    #         # comment'
    #}}}
    # We append a `C-A` character to the abbreviations using `--set-cursor`.{{{
    #
    # They will need a special processing later.
    #}}}
    # We replace a leading space in the RHS with a `C-B` character.{{{
    #
    # To preserve it from `string replace --regex '^\S*\s*' ''`.
    #
    # Note that the  reason we might write  a leading space at  the start of
    # the RHS of an abbreviation is to prevent the command from being logged
    # in fish history after being executed.
    #}}}
    # We *un*quote `{1}` in the `:vimgrep` command.{{{
    #
    #     +"vimgrep /^abbr --add "{1}" \\\C/ ~/.config/fish/**/*.fish" \
    #                            ^   ^
    #
    # Those  double quotes  do *not*  quote  `{1}`.  On  the contrary,  they
    # prevent it to be embedded  inside our `"vimgrep ..."` string.  We need
    # to do  that, because when fzf  will replace `{1}`, it  will put single
    # quotes around:
    #
    #    > {} in the command  is  the  placeholder  that is replaced to the
    #    > **single-quoted string** of the current line.
    #
    # Source: `man fzf /OPTIONS/;/Preview/;/single-quoted`
    #
    # Test:
    #
    #     $ echo 'a b' | fzf --bind='alt-e:become(echo ",{1},")'
    #     # press: alt-e
    #     ,'a',
    #      ^ ^
    #
    #     $ echo 'a b' | fzf --bind='alt-e:become(echo ,{1},)'
    #     # press: alt-e
    #     ,a,
    #
    # This means  that if  we let `{1}`  inside our  `"vimgrep ..."` string,
    # those single  quotes will  be preserved/embedded.   But we  don't want
    # them;  Vim would  wrongly  parse them  as part  of  the pattern  we're
    # looking for.
    #}}}
    abbr --show \
        | string unescape \
        | sed '/--\(function\|regex\)\|^\s*#/d;
               /--set-cursor/s/$/\x01/;
               s/.*--\s\+//;
               s/\s/\t/;
               s/\t /\t\x02/' \
        | column -s\t -t \
        | fzf --bind='alt-e:execute(editor \
               +"vimgrep /^abbr --add "{1}" \\\C/ ~/.config/fish/**/*.fish" \
               +"cclose | normal! zvzz" >$(tty))' \
        | string replace --regex '^\S*\s*' '' \
        | string replace --regex '\x02' ' ' \
)
commandline --function repaint

if test -z "$expanded_abbreviation"
    return
end

# If the chosen abbreviation is defined  with `--set-cursor`, we want to set
# the cursor where the `%` marker is written (and erase the marker).
if string match --regex --quiet -- '\x01' $expanded_abbreviation
    set -f expanded_abbreviation $(string replace --regex -- '\x01' '' $expanded_abbreviation)
    set -f cursor_pos $(string match --regex --index -- '%' $expanded_abbreviation)
    # `string-match(1)` + `--index` actually outputs 2 numbers: `column length`.
    # We're only interested in `column`.
    set -f cursor_pos $(string split -- ' ' $cursor_pos)
    set -f old_pos $(commandline --cursor)
    set -f cursor_pos $(math "$cursor_pos[1] + $old_pos - 1")

    # erase the marker
    set -f expanded_abbreviation $(string replace --regex -- '%' '' $expanded_abbreviation)
end

# Don't let  the expansion overwrite  the current command-line;  just append
# it.  This is useful for global abbreviations  which are often the end of a
# pipeline (e.g. `2>&1 | less`).
commandline --append -- $expanded_abbreviation

if test -n "$cursor_pos"
    commandline --cursor -- $cursor_pos
end
