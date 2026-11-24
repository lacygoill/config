# Purpose: Support bash-specific syntaxes.{{{
#
# If the command-line  contains a bash-specific syntax, just write  it in a bash
# script, and  execute the latter.   This assumes that the  command-line doesn't
# mix bash-specific syntaxes with fish-specific syntaxes.
#}}}
# Purpose: Remove possible useless trailing newline.{{{
#
# That often happens when we copy-paste a command.
# To reproduce:
#
#     # press: C-x C-e
#     :0 put ='echo x'
#     # press: ZZ
#
# ---
#
# If you have such commands in your history and you want to find them to remove the newlines:
#
#     :split ~/.local/share/fish/fish_history
#     :% substitute/\\n\ze\n\s*when: \d\+$//c
#}}}

set --global _execute_tmp_file_prefix $TMPDIR/fish/bash

function my-execute #{{{1
    # remind us about a forgotten abbreviation
    _abbr_reminder true

    set -f cmdline $(commandline --current-buffer | string collect)

    # Let's try to emulate a `HISTIGNORE`-like  mechanism, so that fish does not
    # log in `$__fish_data_dir/fish_history` a  long and useless `ls(1)` command
    # whenever we execute  our `l` abbreviation.  Alternatively,  you could also
    # temporarily set `fish_history` to an empty string.
    #
    # Note that this  does not prevent the command from  being temporarily saved
    # in the current session's `$history`.
    if string match --quiet -- 'ls *' "$cmdline"
        set --global fish_private_mode yes
    end
    if test "$cmdline" = 'l'
        set --global fish_private_mode yes
    end

    # Remove a possible useless and awkward trailing newline.{{{
    #
    # When we  copy-paste a linewise text  (from Vim, Firefox, ...),  a trailing
    # newline  is pasted.   It looks  weird.  And  it's awkward  to edit  such a
    # command when we pull it back from the history.
    #
    # BTW, to  reproduce the issue with  a linewise text copied  in Firefox, you
    # might need  to move the cursor  *below* the copied text,  before releasing
    # the mouse left-click.   If you release the left-click while  the cursor is
    # on the last line of the selected  text (i.e. *not* below), the copied text
    # won't include a trailing newline.
    #}}}
    # `--is-valid`: But not while we're typing a multiline string.{{{
    #
    #     $ echo 'a
    #     # press Enter twice, then "b'", then Enter once
    #     # expected: this is echo'ed:
    #     a
    #
    #     b
    #}}}
    if commandline --is-valid
        set -f non_trimmed_cmdline $(commandline --current-buffer)
        if test -z "$non_trimmed_cmdline[-1]"
            commandline --replace -- $cmdline
        end
    end

    # We might  copy-paste a command starting  with a dollar sign  (which stands
    # for the prompt).  That would cause an error.  Eat it.
    if string match --quiet --regex -- '^\$\s+' $cmdline
        set -f cmdline $(string replace --regex -- '^\$\s+' '' $cmdline | string collect)
        commandline --replace -- $cmdline
    end

    # Highlight output of `$ cmd --help` or `$ cmd subcmd --help`:
    # https://github.com/sharkdp/bat#highlighting---help-messages
    if string match --quiet --regex -- '^\s*\S+\s+(\S+\s+)?--help\s*$' $cmdline
        set -f cmdline $cmdline' | bat --language=help --plain'
        commandline --replace -- $cmdline
    end

    # support bash-specific syntaxes
    set -f process_substitution ' <\('
    # single or double
    set -f quote '[\x22\x27]'
    # Don't add a `$` anchor.{{{
    #
    # `<<'EOF'` is not necessarily at the end of the line:
    #
    #                  v---------v
    #     $ tee <<'EOF' /tmp/sh.sh
    #         echo 'some command'
    #     EOF
    #}}}
    set -f heredoc " <<-?\s*($quote?)\w+\1"
    set -f here_string ' <<<'
    for line in $cmdline
        if string match --quiet --regex -- $process_substitution'|'$heredoc'|'$here_string $line
            _execute_bash_syntax
            return
        end
    end

    commandline --function execute
end

function _erase_fish_private_mode --on-event=fish_prompt #{{{1
    set --erase fish_private_mode
end

function _execute_bash_syntax #{{{1
    # Create a temporary file and store its path into `tmp_file`.{{{
    #
    # The argument passed to `mktemp(1)` is interpreted as a template.
    # Inside, any `X` will be replaced at runtime with an alphanumeric character.
    #}}}
    set -f tmp_file $(mktemp $_execute_tmp_file_prefix.XXXXXXXXXX)

    # highlight the code with `bat(1)`
    printf 'sed "1d" %s | bat --language=bash --color=always --style=plain\n' $tmp_file >$tmp_file

    set -f cmdline $(commandline --current-buffer | string collect)
    echo $cmdline >>$tmp_file
    set -f cmdline 'bash '$tmp_file
    commandline --replace -- $cmdline
    commandline --function execute
end

function _remove_fish_bash_tmp_files --on-event=fish_exit #{{{1
# Don't hook into `fish_postexec`.{{{
#
# We want to keep being able to re-run the command simply by pressing:
# `C-p Enter`
#}}}
    for file in $_execute_tmp_file_prefix.*
        rm -- "$file"
    end
end
