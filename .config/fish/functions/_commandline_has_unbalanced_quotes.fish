# Purpose: Test whether we're inside a string which is not properly terminated.
# This is useful to avoid noisy errors when we run `eval` on some user input.
#
# ---
#
# Adapted from `$__fish_data_dir/functions/__fish_commandline_is_singlequoted.fish`.
# The latter is deprecated and will be removed in the future.
function _commandline_has_unbalanced_quotes
    set -f current_token $(commandline --current-token --cut-at-cursor | string collect)

    # `__fish_tokenizer_state` is defined here:
    # `$__fish_data_dir/functions/__fish_tokenizer_state.fish`
    set -f tokenizer_state $(__fish_tokenizer_state -- $current_token)

    string match --quiet 'single*' -- $tokenizer_state \
        || string match --quiet 'double*' -- $tokenizer_state
end
