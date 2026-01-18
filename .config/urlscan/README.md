# How did you get the original config file?

    $ urlscan --genconf

# How to disable a command bound to a key by default?

In the config file, look for the `keys` object.
In its value, set your key to `""`.

For example:

    "keys": {
        ...
        "x": "",
        ...
    }

# How to change the color of some element of the UI?

In the config file, look for the `default` color scheme.
In the definition of the latter, look for the name of the UI element you want to
customize:

   - header
   - footer
   - search
   - msgtext
   - msgtext:ellipses
   - urlref:number:braces
   - urlref:number
   - urlref:url
   - url:sel

In the list containing the name of your UI element, there should be 3 more items
setting colors and attributes.  For example:

    [
        "header",
        "white",
        "dark blue",
        "standout"
    ]

Here, the list sets the appearance of the header.
The foreground color is white and the background color is dark blue.

To get a list of all possible color values, see:
<http://urwid.org/manual/displayattributes.html#display-attributes>
