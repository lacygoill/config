# print all the files where a completion can be found for a given command

function whichcomp
    set -f funcname $(status current-command)
    if test "$(count $argv)" -ne 1
        printf 'Usage: %s <COMMAND_NAME>
Example: %s mpv\n' $funcname $funcname
        return 1
    end

    set -f cmd $argv[1]
    # `man fish-language /SHELL VARIABLES/;/Special variables/;/fish_complete_path`
    for dir in $fish_complete_path
        if test -e "$dir/$cmd.fish"
            echo "$dir/$cmd.fish"
        end
    end
end
