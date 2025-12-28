# pylint: disable=undefined-variable

# What's the workflow to quickly update this color scheme?{{{
#
# First, you need a shell command to start `pudb`.
#
# Find a python script; for example `$(which tldr)`.
# Find a command using this script; for example:
#
#     $(which tldr) /home/lgc/VCS/kitty/docs/_build/epub/kitty.epub
#       ^---^
#       necessary for later
#       the python interpreter needs an absolute path to find the script
#
# Prefix the command with `pudb`:
#
#     $ pudb $(which tldr) /home/lgc/VCS/kitty/docs/_build/epub/kitty.epub
#       ^--^
#
# ---
#
# Now, find an element in the TUI interface for which you don't like the color.
# Let's say, this color is blue.
# In this scheme, it could be referred to via any of these:
#
#    - `dark_blue`
#    - `light_blue`
#    - `light_cyan`
#    - `dark_cyan`
#
# Find which token is responsible for the color of your element:
#
#     :% substitute/dark_blue/white/g
#     # if the color of your element does not change, then undo
#     :% substitute/light_blue/white/g
#     # in pudb, press `q` twice to quit, then restart the shell command
#     # if the color of your element does not change, then undo
#     ...
#
# Finally, once you found the token, you need to find the exact occurrence.
#}}}
# What color values can I use?{{{
#
# You can  use `default` to refer  to your terminal's default  foreground color.
# The latter is used to highlight the output of shell commands.
#
# You can use `h0` to `h256` to refer to all the colors in your terminal's palette.
#
# Finally, to refer to the first 16 colors of your terminal, you can use these names:
#
#   - `black` (aka "dark black")
#   - `dark gray` (aka "light black")
#
#   - `dark red`
#   - `light red`
#
#   - `dark green`
#   - `light green`
#
#   - `yellow` (aka "light yellow")
#   - `brown` (aka "dark yellow")
#
#   - `dark blue`
#   - `light blue`
#
#   - `dark magenta`
#   - `light magenta`
#
#   - `dark cyan`
#   - `light cyan`
#
#   - `light gray` (aka "dark white")
#   - `white` (aka "light white")
#}}}

# Give the colors some comprehensible names: {{{1

black = "h235"
blacker = "h233"
dark_cyan = "h24"
dark_gray = "h241"
dark_blue = "h20"
dark_green = "h22"
dark_magenta = "h141"
dark_red = "h88"
dark_teal = "h23"
light_blue = "h111"
light_cyan = "h80"
light_gray = "h252"
light_green = "h113"
light_red = "h160"
medium_gray = "h246"
salmon = "h223"
orange = "h173"
white = "h255"
yellow = "h192"

# Set the palette: {{{1

# What's this `palette.update()` function?{{{
#
# I don't know, but it seems to be the way to build your own scheme:
# https://github.com/inducer/pudb/blob/main/examples/theme.py
#
# I *think* it's defined in `$ locate pudb/debugger.py`:
#
# https://github.com/inducer/pudb/blob/0917e51e9a7349408b36e7ac1119f6c425b12fbf/pudb/debugger.py#L493
# https://github.com/inducer/pudb/blob/0917e51e9a7349408b36e7ac1119f6c425b12fbf/pudb/debugger.py#L525
#}}}
#   How do you use it?{{{
#
# According to the previous file example, its syntax is:
#
#     palette.update({
#         "setting_name": (foreground_color, background_color),
#         ...
#     })
#}}}
# TODO: List the names of all the entries which we can set in the palette.{{{
#
# Like `background`, `selectable`, `focused selectable`, ...
# See `$ locate pudb/theme.py`.
# I think they're all listed in `INHERITANCE_MAP` and `BASE_STYLES`.
#}}}
palette.update({
# TODO: Re-organize the entries, so we can find the one we want faster.
    # base styles
    'background': (black, salmon),
    # background of variables and stack views
    'selectable': (black, light_gray),
    'focused selectable': (black, light_cyan),
    # TODO: What's this `add_setting()`?
    'hotkey': (add_setting(black, 'bold, underline'), salmon),
    'highlighted': (black, yellow),

    # general ui
    'header': (add_setting(black, 'bold'), salmon),
    'group head': (dark_blue, salmon),
    'dialog title': (add_setting(white, 'bold'), dark_blue),
    # various input fields, and buttons (like `< Clear  >` in shell view)
    'input': (black, yellow),
    'focused input': (black, light_cyan),
    'warning': (add_setting(dark_red, 'bold'), white),
    'header warning': (add_setting(dark_red, 'bold'), salmon),

    # source view
    'source': (black, light_gray),
    # line which is about to be executed
    'current source': (black, white),
    'breakpoint source': (dark_red, salmon),
    'line number': (dark_gray, white),
    'current line marker': (dark_red, white),
    'breakpoint marker': (dark_red, white),

    # sidebar
    # Variables
    'sidebar one': (black, light_gray),
    # Stack
    'sidebar three': (black, light_gray),
    # Breakpoints
    'sidebar two': (dark_blue, light_gray),

    'focused sidebar one': (black, light_cyan),
    'focused sidebar three': (dark_gray, light_cyan),
    'focused sidebar two': (dark_blue, light_cyan),

    # variables view
    'highlighted var label': (dark_blue, yellow),
    'return label': (white, dark_blue),
    'focused return label': (salmon, dark_blue),

    # stack
    'current frame name': (add_setting(white, 'bold'), dark_cyan),
    'focused current frame name': (add_setting(black, 'bold'), light_cyan),

    # shell
    'command line output': (add_setting(dark_gray, 'bold'), light_gray),

    # Code syntax
    # `class`, `def`, `exec`, `lambda`, `print`
    'keyword2': (dark_magenta, light_gray),
    # "import", "from", "using"
    'namespace': (dark_magenta, light_gray),
    'literal': (dark_red, light_gray),
    #  Exception names
    'exception': (dark_red, light_gray),
    'comment': (dark_gray, light_gray),
    'function': (dark_blue, light_gray),
    # `self`, `cls`
    'pseudo': (dark_gray, light_gray),
    # `range`, `dict`, `set`, `list`, etc.
    'builtin': (light_blue, light_gray),
})

# TODO: Should we set more items?{{{
#
# From `$ locate pudb/theme.py`:
#
#     Reference for some palette items:
#
#      'operator'  : "+", "-", "=" etc.
#                    NOTE: Does not include ".", which is assigned the type 'source'
#      'argument'  : Function arguments
#      'dunder'    : Class method names of the form __<name>__ within
#                   a class definition
#      'magic'     : Subset of 'dunder', methods that the python language assigns
#                   special meaning to. ('__str__', '__init__', etc.)
#      'keyword'   : All keywords except those specifically assigned to 'keyword2'
#                    ("from", "and", "break", "is", "try", "True", "None", etc.)
#
# Also see `INHERITANCE_MAP` and `BASE_STYLES`.
#
# Edit: If we merge the entries of all  the builtin color schemes, and we remove
# the entries which we've already set, we get this list:
#
#     argument
#     button
#     class
#     command line clear button
#     command line error
#     command line focused button
#     command line input
#     command line prompt
#     docstring
#     fixed value
#     focused button
#     focused command line error
#     focused command line output
#     focused sidebar
#     keyword
#     operator
#     punctuation
#     string
#}}}
# TODO: Should we "link" some items?
# Most builtin themes link these two:
link("current breakpoint", "current frame name")
link("focused current breakpoint", "focused current frame name")
# In addition, `agr-256` links this one:
link("focused breakpoint", "focused selectable")
# TODO: Document this `link()` function.
