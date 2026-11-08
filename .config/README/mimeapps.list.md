# How to modify this file?

You can edit it manually, or use an `xdg-mime(1)` command:

    $ xdg-mime default atril.desktop application/epub+zip

# When is a semicolon needed?

When you want to specify 2 consecutive desktop filenames:

    video/mp4=mpv.desktop;vlc.desktop
                         ^

Otherwise, it's not useful.  In particular, it's useless at the end of a line:

    text/html=firefox.desktop;
                             ^

I suggest you remove it.
