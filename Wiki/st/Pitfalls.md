# The compilation fails!

Did you apply a patch between now and the last successful compilation?

If so, run vimdiff on the `config.h` and `config.def.h` files.
If there are entirely new lines (not simple change of values), try to merge them
by pressing `dp`.

This is necessary, for example, if you build st, then apply the Xresource patch,
then try to rebuild.

The patch  adds new  lines into  `config.def.h`, but  not to  `config.h` because
the  latter  is  created  by  `make(1)`,  and  `make(1)`  does  *not*  duplicate
`config.def.h` into `config.h` if it already exists.

Another solution is to  remove `config.h`, but then you lose  all the values you
changed (like the colors for example).

# I'm trying to paste the primary selection by pressing the middle-click of the mouse.  It doesn't work!

If you're in tmux, press shift+middle-click.
Or, temporarily disable the mouse (`pfx M-m`).

See: <https://stackoverflow.com/questions/17445100/getting-back-old-copy-paste-behaviour-in-tmux-with-mouse>

# I'm trying to preview an image.  It constantly gets erased!

So, your issue is that the image  often [disappears][3] when you move to another
file then come back.

Solution: use [ueberzug][4] instead of w3mimgdisplay to preview an image:

    $ sudo apt install ueberzug
    $ sed -i'.bak' '/set\s\+preview_images_method/s/.*/set preview_images_method ueberzug/' ~/.config/ranger/rc.conf

---

Alternatively, you  could try to [increase the value of `st.xfps`][5]  to 300 or
higher; but last time I tried, it didn't help.

You  can also  press `C-l`,  maintain the  key pressed  for a  short time,  then
release `l` (but maintain `Ctrl`).
The image should be redrawn.
But for some  reason, as soon as  you release `Ctrl`, the image  is erased again
(because of xcape which sends an Escape?).
