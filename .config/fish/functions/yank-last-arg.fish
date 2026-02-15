set --global _YLA_index 0

function yank-last-arg
    if test "$status_generation" -eq 0
        return
    end

    # After yanking  the last argument  of a command, we  might want to  yank an
    # earlier argument from the same command.   Make sure we start from the last
    # but one.
    set --global _YNA_index -1
    # increment index of command in history from which we yank the last argument
    set --global _YLA_index $(math "$_YLA_index + 1")
    # If  we get  beyond  the very  first command  executed  during the  current
    # session, cycle back to the last one.
    if test "$_YLA_index" -gt "$status_generation"
        set --global _YLA_index 1
    end

    # split the command into its arguments
    set --global _YLA_args $(echo $history[$_YLA_index] \
        | fish_indent --dump-parse-tree 2>&1 \
        | grep -E '^[! ]*(argument|string):' \
        | string match --regex "'.*'" \
        | string trim --chars="'" \
    )

    # there might be an option before the argument (e.g. `--option=arg)`
    if ! set --query _YLA_option
        set -f current_token $(commandline --current-token)
        string match --regex --quiet '^(?<option>-[^\s=]+=)' -- $current_token
        set --global _YLA_option $option
    end

    commandline --replace --current-token -- "$_YLA_option"$_YLA_args[-1]
end

function _yank_last_arg_reset --on-event=space_inserted
    set --global _YLA_index 0
    set --erase --global _YLA_args
    set --erase --global _YLA_option
end
