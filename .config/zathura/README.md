# Mapppings
## What are the modes that zathura can recognize in a mapping?

   - normal (default)
   - fullscreen
   - index (TOC accessed via Tab)

### How to use one in a mapping?

Pass the optional argument `[fullscreen]` or `[index]` to the `:map` command.

Example:

    map [fullscreen] f toggle_fullscreen

For more info, `man zathurarc /Mode`.

##
## Am I in fullscreen mode when I press Alt-F10?

No.

From the point of view of zathura, you're not in fullscreen mode.
