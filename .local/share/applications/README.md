# Where can I find more information about the format of a .desktop file?

<https://standards.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#introduction>

# What should I do after writing a desktop file?

Pass it to `desktop-file-validate(1)` to check whether it contains errors.

    $ desktop-file-validate mypgm.desktop

Or press `|c` while in Vim (custom mapping).

##
# Where did you find the code for
## `firefox`?

<https://github.com/mozilla/sumo-kb/blob/main/install-firefox-linux/firefox.desktop>

    $ wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop \
        --directory-prefix="$HOME/.local/share/applications"

---

If you install Firefox from a tarball,  when you first start it, you're asked if
you want  to make it your  default web browser;  and if you answer  yes, Firefox
adds a few MIME types in `~/.config/mimeapps.list`:

    application/x-extension-htm=userapp-Firefox-Q8YQ61.desktop
    text/html=userapp-Firefox-Q8YQ61.desktop
    x-scheme-handler/http=userapp-Firefox-Q8YQ61.desktop
    ...

Some of  them were missing  from the  downloaded `firefox.desktop`, so  we added
them into the `MimeType=` line.

## `st`?

<https://wiki.archlinux.org/index.php/St#Desktop_entry>

##
## `typometer`?

I looked at the desktop file of gVim, and copied the most useful keys.

### Why do you run `$ sh -c`?

To expand the environment variable `$HOME`.
It's not expanded by default, so we rely on `sh(1)` to do it instead.

See: <https://stackoverflow.com/a/8980518/9780968>

### Why double quotes (`$ sh -c "..."`) and not single quotes (`$ sh -c '...'`)?

If you use single quotes, `desktop-file-validate(1)` will complain:

    /home/user/.local/share/applications/typometer.desktop: error: value "sh -c 'java -jar $HOME/bin/typometer-1.0.1.jar'" for key "Exec" in group "Desktop Entry" contains a reserved character ''' outside of a quote
    /home/user/.local/share/applications/typometer.desktop: error: value "sh -c 'java -jar $HOME/bin/typometer-1.0.1.jar'" for key "Exec" in group "Desktop Entry" contains a reserved character '$' outside of a quote
    /home/user/.local/share/applications/typometer.desktop: error: value "sh -c 'java -jar $HOME/bin/typometer-1.0.1.jar'" for key "Exec" in group "Desktop Entry" contains a reserved character ''' outside of a quote

### Why the double backslash (`\\$HOME`)?

Without, `desktop-file-validate(1)` will complain:

    /home/user/.local/share/applications/typometer.desktop: error: value "sh -c "java -jar $HOME/bin/typometer-1.0.1.jar"" for key "Exec" in group "Desktop Entry" contains a non-escaped character '$' in a quote, but it should be escaped with two backslashes ("\\$")

This is due to the [specification][2]:

>     Note that the  general escape rule for  values of type string  states that the
>     backslash character can be escaped as ("\\") as well and that this escape rule
>     is applied before the quoting rule.
>     As such,  to unambiguously represent a  literal backslash character in  a quoted
>     argument in a  desktop entry file requires the use  of four successive backslash
>     characters ("\\\\").
>     Likewise, a literal dollar sign in a  quoted argument in a desktop entry file is
>     unambiguously represented with ("\\$").

##
# Field code
## What's a field code?

An alphabetic character prefixed by `%` which is replaced at runtime.

>     A number of  special field codes have  been defined which will  be expanded by
>     the file manager or program launcher when encountered in the command line.
>     Field  codes consist  of the  percentage character  ("%") followed  by an  alpha
>     character.

## What's `%F`?

It's replaced with a list of files.
It's useful for apps that can open several local files at once.
Each file is passed as a separate argument to the executable program.

   > If the application can open files the %f placeholder should be specified.
   > When a file is dropped on the application launcher the %f is replaced with
   > the file path of the dropped file. If multiple files can be specified on
   > the command line the %F placeholder should be used instead of %f.

Source:

   - `man xdg-desktop-icon /DESKTOP FILES/;/Exec=`
   - `man xdg-desktop-menu /DESKTOP FILES/;/Exec=`

## What's `%u`?

It's similar to `%f`, except that it's replaced with a URL (and not a file).

   > If the application is able to open URLs in addition to local files then %u
   > or %U can be used instead of %f or %F.

Source:

   - `man xdg-desktop-icon /DESKTOP FILES/;/Exec=`
   - `man xdg-desktop-menu /DESKTOP FILES/;/Exec=`

##
# Keys
## Why do I always need to specify the `Type` key?

Without, you wouldn't be able to run the program from a menu like rofi.
You would get  an error message stating  that no file or  directory matching the
name of the program was found.

From the spec:

>     This specification defines  3 types of desktop  entries: Application (type 1),
>     Link (type 2) and Directory (type 3).
>     To allow the addition of new  types in the future, implementations should ignore
>     desktop entries with an unknown type.

## What's the difference between the `Exec` key and the `TryExec` key?

I think that the value of `TryExec` is used when you start your application from
a menu,  while `Exec` is used  when you start it  from the contextual menu  in a
file manager, which is opened after  selecting one or several files and pressing
a right-click.

IOW, `Exec` can contain a field code like `%F`.

---

Here's how the spec describes `TryExec`:

>     Path  to an  executable file  on  disk used  to  determine if  the program  is
>     actually installed.
>     If  the path  is not  an  absolute path,  the file  is  looked up  in the  $PATH
>     environment variable.
>     If the file is not present or if  it is not executable, the entry may be ignored
>     (not be used in menus, for example).

And `Exec`:

>     Program to execute, possibly with arguments.
>     See the Exec key for details on how this key works.
>     The Exec key is required if DBusActivatable is not set to true.
>     Even if DBusActivatable is true, Exec should be specified for compatibility with
>     implementations that do not understand DBusActivatable.

##
## Where should I put an icon file?

Try one of these directories:

   - `/usr/local/share/icons/hicolor/48x48/apps/`
   - `~/.local/share/icons/hicolor/48x48/apps/`

See: <https://developer.gnome.org/integration-guide/stable/icons.html.en>

### How do I get a picture with the right size and weight?

Download a picture  which represents your application, then  use `convert(1)` to
resize and compress it:

    $ convert your_pic.png -resize 48x48! your_resized_pic.png
                                        ^

The exclamation point forces  the new image to respect the size  48x48 – even if
it messes up the aspect ratio.
Source: <https://www.howtogeek.com/109369/how-to-quickly-resize-convert-modify-images-from-the-linux-terminal/>

---

For example, on [this webpage][3], you can download a [picture][4] for typometer.
But it doesn't have the right size:

    $ file typometer.png
    typometer.png: PNG image data, 190 x 130, 8-bit/color RGB, non-interlaced

Nor the right weight:

    $ ls -lh
    ... 38K ... typometer.png

After running `convert(1)`:

    $ convert typometer.png -resize 48x48! resized_typometer.png

You get the right size, and a more fitting weight:

    $ file typometer.png
    resized_typometer.png: PNG image data, 48 x 48, 8-bit/color RGB, non-interlaced

    $ ls -lh
    ... 5,3K ... resized_typometer.png

##
## What's the purpose of the key
### `Categories`?

>     Categories in which the  entry should be shown in a  menu (for possible values
>     see the Desktop Menu Specification).

### `Comment`?

>     Tooltip for the entry, for example "View sites on the Internet".
>     The value should not be redundant with the values of Name and GenericName.

### `Keywords`?

>     A list of strings which may be  used in addition to other metadata to describe
>     this entry.
>     This can be useful e.g. to facilitate searching through entries.
>     The values  are not  meant for  display, and  should not  be redundant  with the
>     values of Name or GenericName.

### `StartupNotify`?

If set  to true,  it lets  the launcher know  your application  supports startup
notification.

When set to true, the desktop environment will use whatever startup notification
is built in to either your application or your toolkit, to let you know that the
application has started;  e.g. the shape of the cursor  could temporarily change
until the application appears onscreen.

See: <https://developer.gnome.org/integration-guide/stable/startup-notification.html.en>

##
# Reference

[1]: https://stackoverflow.com/questions/8980464/how-do-i-access-an-environment-variable-in-a-desktop-files-exec-line/8980518#comment18641582_8980518
[2]: https://standards.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#exec-variables
[3]: https://pavelfatin.com/typometer/
[4]: https://pavelfatin.com/images/typometer.png
