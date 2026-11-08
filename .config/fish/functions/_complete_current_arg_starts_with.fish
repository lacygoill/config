#        1 instead of 2 to avoid overwriting a helper function from `$__fish_data_dir/functions/`
#        v
function _complete_current_arg_starts_with
    set -f current_arg $(commandline --current-token)
    set -f pattern $argv[1]
    if string match --quiet --regex -- $pattern $current_arg
        return 0
    end
    return 1
end
