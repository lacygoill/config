# open the man page for the name of the first command on the command-line
function man-page-for-command
    set --global _saved_input $(commandline --current-buffer | string collect)

    set -f tokens $(string split --no-empty -- ' ' $_saved_input)
    set -f cmd $tokens[1]
    if test "$cmd" = 'sudo'
        set -f cmd $tokens[2]
    end

    man $cmd
end

function _restore_input --on-event=fish_postexec
    if test -n "$_saved_input"
        commandline --replace -- $_saved_input
        set --erase --global _saved_input
    end
end
