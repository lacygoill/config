set --global _YNA_index -1

function yank-nth-arg
    set --global _YNA_index $(math "$_YNA_index - 1")

    set -f prev_arg $_YLA_args[$_YNA_index]
    # Handle case where we've moved back  beyond first argument: cycle forward to
    # last argument again.
    if ! set -f --query prev_arg[1]
        set --global _YNA_index -1
        set -f prev_arg $_YLA_args[-1]
    end

    commandline --replace --current-token -- "$_YLA_option"$prev_arg
end

function _yank_nth_arg_reset --on-event=space_inserted
    set --global _YNA_index -1
end
