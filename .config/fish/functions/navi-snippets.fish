function navi-snippets
    set -f current_process $(commandline --current-process)
    set -f leading_whitespace $(string match --regex -- '^\s*' $current_process)
    set -f current_process $(string trim -- $current_process)
    set -f navi_opts --path=$HOME/.config/navi/snippets/ --print

    if test -z "$current_process"
        # `--print` makes navi print the chosen snippet to stdout, instead of executing it.{{{
        #
        # This  lets   us  insert  the   snippet  on  the   command-line,  using
        # `commandline --insert` and a command substitution.
        #}}}
        commandline --insert -- $(navi $navi_opts)
        commandline --function repaint
        return
    end

    set -f snippet $(navi $navi_opts --query=$current_process)
    commandline --replace --current-process "$leading_whitespace"$snippet
    commandline --function repaint
end
