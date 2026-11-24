# Configuration
## How to create a color scheme for st?

Use [terminal.sexy][1], and export your scheme to st by selecting “Simple Terminal”.

## ?

Our current white color makes several things unreadable:

    $ rm -rf ...

This command is highlighted in a red background, and a white foreground.
But the white is gray.

Look also at the cmus interface.
And look at this:

    $ highlight -O ansi ~/bin/python/xkbmapd.py

The  issue  is  in  `~/.config/st/patches/01_custom_config.diff`;  we've  chosen
`#808080` for white.
We did this, because we've copied the value from `~/.Xresources`.
There was a reason.
See whether you can find a value which makes a white text always readable.

But this is weird...
Why does the same hexcode makes cmus readable in urxvt, but not in st?

##
## patches to apply
### ?

Which patches should we apply?

<https://st.suckless.org/patches/bold-is-not-bright/>

Review the other patches.

### ?

Explain how to create a patch.
I.e. create a temporary branch, commit, edit files, and run `$ git diff`.

###
## patches to avoid
### clipboard

<https://st.suckless.org/patches/clipboard/>

It seems it only makes us lose the  ability to paste some selected text from the
browser into the terminal via middle click.
It's inconsistent with all other terminal emulators we're using.
So, don't use it.

### fix keyboard input

<https://st.suckless.org/patches/fix_keyboard_input/>

This patch breaks the Enter key.
When you press Enter, it inserts `09 5u` on the command-line.

###
### Xresources
#### How to use it?

<https://st.suckless.org/patches/xresources/>

Fix the index of the foreground, background, and cursor colors:

    $ sed -i '/background/s/[0-9]\+/0/; /foreground/s/[0-9]\+/7/; /cursorColor/s/[0-9]\+/256/' /path/to/patch.diff

Finally, apply it:

    $ patch </path/to/patch.diff

---

The latest version atm is:
<https://st.suckless.org/patches/xresources/st-xresources-20190105-3be4cf1.diff>

The header of the patch reads:
   > Subject: [PATCH] Update base patch to 0.8.1

Which means that it should work on st version 0.8.1.
I've tested it against 0.8.2, and it still works.

The patch sets  the foreground, background, and cursor colors,  with the indices
256, 257, 258, while [it should use 0, 7 and 256][2].

If you don't fix the patch, these colors will be wrong.
That is, the only way to set the background color of st like in urxvt is to have
these lines:

                             v
    unsigned int defaultbg = 0;
    ...
    { "background",   STRING,  &colorname[0] },
                                          ^

Same thing for the foreground and cursor colors.

Besides, without the fix, when the output of a command contains a tab character,
it will occupy almost a whole line on the terminal.
This is because there's no color indexed by 258 in the array `*colorname[]`:

    ...
    "cyan",
    "white",

    [255] = 0,

    /* more colors can be added after 255 to use with DefaultXX */
    [256] = "#cccccc",
    [257] = "#555555",

You can test this issue by running `infocmp(1)`.
If the output is not readable, it's because you didn't fix the patch.
Although, for  some reason, the issue  is not present inside  tmux (even without
any tmux config).

#### Why should I avoid it?

It provides little benefit: a compilation takes little time.

---

It adds complexity: I have a hard time  understanding which color is going to be
applied when configuring `config.h`.

---

It can lead to bugs if you don't fix it, like we explained earlier.

---

Even after being fixed, the arguments of a command are invisible.
This is due to our zsh syntax highlighting plugin.
More specifically, this line:

    ZSH_HIGHLIGHT_STYLES[default]='fg=black'

I found one – weird – solution:

    ZSH_HIGHLIGHT_STYLES[default]='fg=white'
                                      ^---^

Or:

    ZSH_HIGHLIGHT_STYLES[default]='fg=7'
                                      ^

It probably means that sth is wrong in our patched `config.h`.

##
# Usage
## How to start st with an arbitrary geometry?

Use the `-g` option.

    $ st -g=<cols>x<rows>[{+-}<xoffset>{+-}<yoffset>]

For fullscreen in a 1080p screen, try:

    $ st -g=120x35

##
# Reference

[1]: https://terminal.sexy/
[2]: https://github.com/dcat/st-xresources/issues/3#issue-394957047
[3]: https://github.com/ranger/ranger/issues/856
[4]: https://github.com/seebye/ueberzug
[5]: https://github.com/ranger/ranger/issues/759#issuecomment-276355995
[6]: https://www.reddit.com/r/unix/comments/8tjcen/how_to_change_the_color_of_the_vim_cursor_in_st/e197b3t/
