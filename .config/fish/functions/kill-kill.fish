function kill-kill
    set -f cmdline $(commandline --current-buffer)
    set -f pos $(commandline --cursor)

    # We might paste a commented block of fish code which we want to execute.
    # If the first line is a shell command, uncomment it (and the whole block with it).{{{
    #
    # For example:
    #
    #     # $ sudo netstat --listening --tcp --numeric --program \
    #     #     | sort --key=7bn,7 \
    #     #     | tail --lines=+3
    #
    #     →
    #
    #     sudo netstat --listening --tcp --numeric --program \
    #       | sort --key=7bn,7 \
    #       | tail --lines=+3
    #}}}
    if string match --quiet --regex -- '^\s*#\s+\$' $cmdline[1]
        set -f uncommented "$(string replace --regex -- '^\s*#\s*(\$\s*)?' '' $cmdline)"
        commandline --replace -- $uncommented
        commandline --function repaint
        return
    end

    # Kill (possibly long multi-line) trailing comment.
    #
    #                                         inline comment (syntax which we use in abbreviations)
    #                                         v--v
    if string match --quiet --regex -- '^\s*#|  # ' $cmdline
        set -f without_comment "$(string replace --regex -- '(^\s*#|  # ).*' '' $cmdline)"
        commandline --replace -- $without_comment
        commandline --function repaint
        commandline --cursor -- $pos
        return
    end

    # Kill option:
    #
    #     $ vim --output=$TMPDIR/trace.log
    #           ^-------^
    set -f token $(commandline --current-token)
    if string match --quiet --regex -- '^--[^-]*=' $token
        set -f filepath $(string replace --regex -- '^--[^-]*=' '' $token)
        commandline --replace --current-token -- $filepath
        return
    end

    # Kill current token.
    if test -n "$token"
        commandline --replace --current-token ''
        return
    end

    # Kill process under cursor (useful to remove something like `| wc -l`).
    commandline --replace --current-process ''
    commandline --function backward-kill-bigword

    # Don't kill too much accidentally.
    if test -z "$(commandline)"
        commandline --function undo
    end
end
