# What's the purpose of the patch
## `custom_config`?

It  applies our  configuration  preferences, like  which  font, colors,  default
geometry we want to use.

## `boxdraw`?

Without it, the horizontal  line between 2 tmux panes is  made up of hyphen-like
characters separated by a few amount of space.

With the patch, the line is prettier because continuous.

More generally, the patch makes st better handle similar drawing characters.

You can configure the patch by setting the constants:

   - `boxdraw`
   - `boxdraw_bold`
   - `boxdraw_braille`

inside `~/.config/st/patches/03_st-boxdraw_v2-0.8.3.diff`.

You can try to read this demo file to check the effect of the patch:
<https://salsa.debian.org/printing-team/cups/raw/debian/master/cups/utf8demo.txt>
Move at the bottom, where drawings have been written.

---

   > Graphic lines and blocks characters such as those used by dialog, tree, tmux etc
   > sometimes align with gaps - which doesn't look very nice.
   > This can depend on font, size, scaling, and other factors.
   >
   > Braille is  also increasingly used  for graphics (mapscii, vtop,  gnuplot, etc),
   > and may look or align nicer when rendered as "pixels" instead of dots.
   >
   > This patch adds options to render most of the lines/blocks characters and/or the
   > the braille ones without using the  font so that they align perfectly regardless
   > of font, size or other configuration values.
   >
   > Supported codepoints are U2500 - U259F except dashes and diagonals, and U28XX.

## `OSC_10_11_12`?

If you start  Vim and press `coC` to  switch the color scheme, the  color of the
cursor is not updated.

And if  you start  st from  another terminal,  then after  quitting Vim  and st,
you'll see this error message in the first terminal:

    erresc: unknown str ESC]112ESC\

The issue is that st doesn't support this sequence:

    OSC Ps ; Pt BEL
    ...
    Ps = 1 2  -> Change text cursor color to Pt.

For more info, have a look at this file (requires the deb package xterm):

    /usr/share/doc/xterm/ctlseqs.txt.gz

---

Solution 1:

Apply the `OSC_10_11_12` patch.

[Source][1]

---

Solution 2:

Give up this feature.

In this case, you can remove this line from in `~/.config/tmux/terminal-overrides.conf`:

    set -as terminal-features '*:ccolour'

It's responsible for automatically setting the `Cs`/`Cr` terminfo extensions.

##
# Reference

[1]: https://st.suckless.org/patches/osc_10_11_12_2/
