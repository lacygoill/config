# get info
## How to get the name of the command executed when I press a key?

     $ mpv --input-test --force-window --idle
     # press your key
     # close with alt+f4

## How to get the list of names for the special keys?

    $ mpv --input-keylist

## Where can I find details about all the available commands?

<https://github.com/mpv-player/mpv/blob/master/DOCS/man/input.rst>

##
# bind
## `#` is already used to begin a comment.  So, how to assign a key to `#`?

Use `SHARP` in your key binding.
Example:

    SHARP cycle audio

##
# unbind
## How to unbind a key?

Use 'ignore'.

Example:

    ctrl+a ignore

## How disable all the default key bindings?

    $ mpv --no-input-default-bindings
