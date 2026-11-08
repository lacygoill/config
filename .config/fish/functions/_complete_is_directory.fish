function _complete_is_directory
    set -f current_token $(commandline --cut-at-cursor --current-token)
    string match --quiet --regex '/$' -- $current_token
end
