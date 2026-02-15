function path-dedup
    # Remove duplicate entries from path-like variables.

    # If we received several names of variables, iterate over them.
    # And for each, re-call the function with a single name argument.
    if test "$(count $argv)" -gt 1
        for varname in $argv
            path-dedup $varname
        end
        return
    end

    set -f varname $argv
    # Make sure the value of this variable will be treated as a path.{{{
    #
    # That is:
    #
    #    - automatically split on colons
    #    - automatically joined using colons when quoted (`echo "$PATH"`) or exported
    #}}}
    # We need to dereference `varname` twice; hence the double dollar.{{{
    #
    # Once to evaluate `varname` into a variable name, like `INFOPATH`.
    # Twice to evaluate `INFOPATH` into its value.
    #}}}
    set --path $varname $$varname
    set -f new_value
    for path_element in $$varname
        # We need to trim possible trailing slashes to normalize the path.{{{
        #
        # Otherwise, a path variable might still contain duplicate elements:
        #
        #     /usr/share
        #     /usr/share/
        #}}}
        set -f path_element $(string trim --right --chars='/' -- $path_element)
        if ! contains -- $path_element $new_value
            set -f --append new_value $path_element
        end
    end
    set --path $varname $new_value
end
