# What's a mimetype?

MIME stands for Multi-purpose Internet Mail Extensions.

A MIME type is a label used to identify a type of data.
Programs use it to determine how to handle the data they receive.

# When should I change the mimetype of a file?

When you double-click on  a file, or use `xdg-open(1)`, and  it doesn't open the
file with the desired program.

#
# How to get the mimetype of a file?

    $ xdg-mime query filetype <file>

Example:

    $ xdg-mime query filetype ~/.vim/vimrc

##
# How to get the default application which handles a particular type of data?

    $ xdg-mime query default <mimetype>

Example:

    $ xdg-mime query default text/plain

## How to set it?

    $ xdg-mime default <app.desktop> <mimetype> ...

Example:

    $ xdg-mime default gvim.desktop text/plain text/x-c application/x-shellscript

### Which pitfall must I avoid before setting it?

Make sure that `<app>.desktop` exists:

    $ locate --ignore-case <app>.desktop

If it doesn't, use a glob to widen the search:

    $ locate '*vim.desktop'
              ^
              any prefix

### In which file is this setting saved?

    ~/.config/mimeapps.list

There might  be other files  (like `~/.local/share/applications/mimeapps.list`);
use `locate(1)` to find them:

    $ locate --ignore-case mimeapps.list

##
# How to set gVim as the default handler for all known text files?

                                                              remove trailing suffix extension
                                                              v--------------------v
    $ find /usr/share/mime/text -iname '*.xml' -exec /usr/bin/basename --suffix=.xml --zero '{}' \+ \
        | xargs --null xdg-mime default gvim.desktop

## How to configure the handler to pass arbitrary options to the gVim command?

You can use your own `gvim.desktop` in your home:

    $ cp /usr/local/share/applications/gvim.desktop ~/.local/share/applications/gvim.desktop

If you do so, it has priority over the system one.

Edit the `Exec` directive to pass the desired options.
