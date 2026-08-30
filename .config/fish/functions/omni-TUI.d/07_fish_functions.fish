set -f chosen_function $(
    # In `--bind=...`,  `--interactive` is  necessary if we  want to  edit a
    # custom function.
    #
    # ---
    #
    # In `--preview`, we can't make fish execute `functions` directly.  It's
    # not reliable enough; it fails for a function which has not been loaded
    # yet.
    # Warning: If you edit a function (`M-e`), after quitting the editor, you might still need to press Enter.{{{
    #
    # Do it if you get this warning:
    #
    #     Warning: the file containing this function has not been saved.
    #     Changes may be lost when fish is closed.
    #}}}
    functions --all \
        | fzf --bind='alt-e:execute(fish --command="funced {} >$(tty)" --interactive)' \
        --preview='fish --command="_function_definition {}" --interactive' \
        --preview-window=nohidden
)
commandline --function repaint

if test -z "$chosen_function"
    return
end

commandline --append -- $chosen_function
