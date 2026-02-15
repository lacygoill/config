sudo --validate || return

# `-O`: true if file exists and is owned by the effective user ID
set -f cmd "[[ -O {} ]] && editor +'set filetype=messages' -- {} || sudoedit -- {}"
# `--preview`:  we need  `tail(1)` because  a log  might be  very long,  and
# `bat(1)` doesn't support a range from the end of a file:
# https://github.com/sharkdp/bat/issues/791#issuecomment-1307992345
begin
    sudo find /var/log $FIND_OPTS \( -name '*.log' -o -name '*.err' -type f \) -print
    find $HOME/.local/pipx/logs $FIND_OPTS -name '*.log' -type f -print
    for file in /var/log/{aptitude,syslog}
        if test -f "$file"
            echo $file
        end
    end
end | sort \
    | fzf --bind="enter:become($cmd)" \
        --bind="alt-e:execute($cmd)" \
        --bind='alt-T:become(sudo tail --follow=name --retry -- {} | bat --language=syslog --paging=never)' \
        --delimiter=/ \
        --header='press alt-T to tail a log' \
        --preview-window=nohidden \
        --preview='sudo tail --lines=500 -- {} | bat --language=syslog --color=always' \
        --with-nth=4..

commandline --function repaint
