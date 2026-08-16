# What's this file?

A configuration file for `/usr/bin/dircolors`.

# What's `dircolors(1)`?

A utility to help you set `$LS_COLORS`.

# What's `$LS_COLORS`?

An environment variable which controls how `$ ls --color` colorizes its output.

##
# How to restore the default config of `dircolors`?

    $ dircolors -p >~/.config/dircolors/config

# How to save the current value of `$LS_COLORS`?

    $ dircolors --bourne-shell

# The output will be a string looking like this:

    LS_COLORS='...'; export LS_COLORS

In a bourne-shell compatibel shell, if you execute this command, it will restore
`$LS_COLORS` as it is now.  Write it somewhere.

# The current value of `$LS_COLORS` is unreadable! How to make it more readable?

    $ echo $LS_COLORS | sed 's/:/\n/g'

# But it's still unreadable!

    $ ~/bin/ls-colors

It will display all the values in `$LS_COLORS` in a human readable format.
In particular, each color value is colorized with the actual color it stands for.

##
# If I change a setting in this file, will it be automatically used by `ls(1)`?

In fish, yes, provided that you remove `~/.cache/fish/dircolors`.
Because we've included this block of code in `~/.config/fish/conf.d/environment.fish`:

    if not test -s "$HOME/.cache/dircolors"
        dircolors $HOME/.config/dircolors | \
        sed -n 's/^LS_COLORS=/set --export LS_COLORS /p' \
            >$HOME/.cache/dircolors
    end
    source $HOME/.cache/dircolors

Just make sure to start a new shell so that `environment.fish` is sourced.

# If I comment all the settings, does `$ ls --color` print its output without any color?

No, `ls(1)` falls back on some internal default config.

# What's a color init string?

It consists of one or more of the following numeric codes:

Attribute codes:

    00=none
    01=bold
    03=italic
    04=underscore
    05=blink
    07=reverse
    08=concealed

Text color codes:

    30=black
    31=red
    32=green
    33=yellow
    34=blue
    35=magenta
    36=cyan
    37=white

Background color codes:

    40=black
    41=red
    42=green
    43=yellow
    44=blue
    45=magenta
    46=cyan
    47=white

# What's the syntax of a setting?

    <item>=<style>;<color>
    <item>=<color>;<style>
    <item>=<style>;<color>;<style>
    ...

An item can contain as many styles/colors as you want, in any order.

`item` can have, among other values:

   - `di` for a directory
   - `fi` for a file
   - `ln` for a symlink
   - ...

`style` can have, among other values:

    ┌────┬───────────────────┐
    │ 00 │ default color     │
    ├────┼───────────────────┤
    │ 01 │ bold              │
    ├────┼───────────────────┤
    │ 30 │ yellow background │
    ├────┼───────────────────┤
    │ 34 │ green background  │
    ├────┼───────────────────┤
    │ 37 │ red background    │
    ├────┼───────────────────┤
    │ 40 │ black background  │
    └────┴───────────────────┘

`color` can have, among other values:

    ┌────┬──────────────┐
    │ 31 │ red          │
    ├────┼──────────────┤
    │ 32 │ green        │
    ├────┼──────────────┤
    │ 33 │ orange       │
    ├────┼──────────────┤
    │ 34 │ blue         │
    ├────┼──────────────┤
    │ 35 │ purple       │
    ├────┼──────────────┤
    │ 36 │ cyan         │
    ├────┼──────────────┤
    │ 37 │ gray         │
    ├────┼──────────────┤
    │ 90 │ dark gray    │
    ├────┼──────────────┤
    │ 91 │ light red    │
    ├────┼──────────────┤
    │ 92 │ light green  │
    ├────┼──────────────┤
    │ 93 │ yellow       │
    ├────┼──────────────┤
    │ 94 │ light blue   │
    ├────┼──────────────┤
    │ 95 │ light purple │
    ├────┼──────────────┤
    │ 96 │ turquoise    │
    └────┴──────────────┘

# Why should I avoid the style attribute `02`?

Here's how it's documented at `man console_codes`:

>     2       set half-bright (simulated with color on a color display)

It makes the terminal emulate the color whose code follows the semicolon, in a
half-bright tone.
The result of this simulation is inconsistent from one terminal to another.
Besides,  you can't  even rely  on the  dircolors syntax  plugin to  correctly
highlight the code `02;...` in this script.

# Where can I find more information about all the numeric codes used in the settings?

See:

   - `man console_codes`
   - `man dir_colors`
