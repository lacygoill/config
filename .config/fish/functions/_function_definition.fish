# Useful for a function which has not been loaded yet.{{{
#
# Example 1:
#
#     $ functions --details omni-TUI-tldr
#     n/a
#
#     $ _function_definition omni-TUI-tldr
#     # Defined in /home/lgc/.config/fish/functions/omni-TUI.fish @ line 186
#     ...
#
# Here, the issue is that the function has not be loaded yet, and can't be found
# by the  autoloading mechanism;  its name  doesn't match the  name of  the file
# where it's defined, because it's just a helper function.
#
# Example 2:
#
#     $ fish --command='functions --details __fish_commandline_insert_escaped'
#     n/a
#
#     $ fish --command='_function_definition __fish_commandline_insert_escaped'
#     # Defined in /home/lgc/.local/share/fish/functions/__fish_shared_key_bindings.fish @ line 204
#     ...
#
# Here,  the issue  is that  the  function is  only loaded  automatically in  an
# interactive shell, and we didn't pass `--interactive` to the `fish` command.
#}}}
function _function_definition --argument-names=fn
    if ! functions --query $fn
        set -f where_is_it \
            $(grep --files-with-matches --recursive "^\s*function\s\+$fn\(\$\|\s\)" $__fish_config_dir $__fish_data_dir)
        if ! set --query $where_is_it[1]
            return
        end
        source $where_is_it
    end

    functions $fn | fish_indent --ansi
end
