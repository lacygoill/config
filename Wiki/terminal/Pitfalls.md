# Some text is wrongly colored in the terminal!
## How to find out its hex color code?

Run Gpick and hover your cursor over the text.
If positioning the cursor accurately is too hard, because the text is too small,
temporarily configure your terminal to use a much bigger font.

## How to find out which color from the terminal's palette, if any, is used?

Let's assume the color – found with Gpick – is `#ab1234`.

Comparing `#ab1234` to *each* color in the terminal's palette would take too much time.
But you don't have to.

First, `#ab1234`  is not repeating  the same  2 digits, so  it's not a  shade of
gray, and you don't have to compare it to the last 24 colors in the palette.
OTOH, if  your color *was* following  the scheme `#xyxyxy`, then  you would only
have to compare it to the last 24 colors in the palette.

Next, compare `#ab1234` to each of the first 16 colors (ANSI palette).

If there's no match, then consider the last two digits of `#ab1234`; i.e. `34`.
Compare them to the last two digits in *any* color of a given column in the palette.
If it doesn't match, `#ab1234` is not in this column.
Repeat until you find a color in a column whose last two digits are `34`; if you
don't find one, `#ab1234` is not in the palette.

If you've found a  color whose last two digits are `34`,  consider the first two
digits in `#ab1234`, i.e. `ab`.
Compare them to the first two digits in *any* color of a square.
If it doesn't match `ab`, `#ab1234` is not in this square.
Repeat until you  find a color in a  square whose first two digits  are `ab`; if
you don't find one, `#ab1234` is not in the palette.

If you've found a  color whose first two digits are `ab`, all  you have to do is
compare each of the  six colors which are simultaneously in  the `ab` square and
in the `34` column.

At worst, you have 16 (ANSI colors) + 6 (columns) + 6 (squares) + 6 (lines) = 34
comparisons to do.

---

Alternatively, use `~/bin/is-it-in-the-palette`, but be aware of the limitations
of this script; they're documented at the top of the file.

#
# I'm trying to combine the color black with the bold attribute.  I get some light gray!

In some sequences, bold is interpreted as bright:

<https://askubuntu.com/questions/875102/gnome-terminal-use-bright-colors-for-bold>

---

The bold  attribute (`\e[1m`) is interpreted  as bold when combined  with direct
RGB colors (true  colors), and with the colors of  the 256-color palette, beyond
the first 16.

However,  the first  16 colors  in the  256-color palette  can be  accessed with
escape sequences  using the numbers 30–37  (first 8), 90–97 (following  8 bright
variants), or 38;5;0–15.

And  if you  combine the  sequences using  the numbers  30–37 with  `\e[1m`, the
latter is interpreted as bold**+bright** (for legacy compatibility reasons).

So, this prints the text “hello” in bold black:

    $ printf '\e[38;5;0;1m  hello  \e[0m\n'

While this prints the same text in bold gray:

    $ printf '\e[30;1m  hello  \e[0m\n'

If you  want to know which  sequence is used by  a program to encode  one of the
first 16 foreground colors in the 256-color palette, have a look at the value of
your terminal's `setaf` capability.

---

Note that st doesn't suffer from this issue provided you applied this patch:
<https://st.suckless.org/patches/bold-is-not-bright/>

##
# I've pasted some text on the command-line, and the shell has automatically run it.  I wanted to edit it!

The [bracketed paste mode][1] fixes [this issue][2].

If you're using zsh, make sure its version is greater than 5.1.
If you're using  bash, make sure its  version is greater than  4.4 (and readline
version is greater than 7).

If you're using  tmux, you must also make sure  that whenever the `paste-buffer`
command is invoked, it's passed the `-p` option.

From `man tmux /paste-buffer`:

   > If -p is specified, paste bracket control codes are inserted around the buffer
   > if the application has requested bracketed paste mode.

---

Here's a short description of the bracketed paste mode:

   > One  of the  least well  known,  and therefore  least used,  features of  many
   > terminal emulators is bracketed paste mode.
   > When you  are in bracketed  paste mode and you  paste into your  terminal, the
   > content will be wrapped by the sequences `\e[200~` and `\e[201~`.
   >
   > [...] it enables something very cool: programs can tell the difference between
   > stuff you type manually and stuff you pasted.
   >
   > [...]
   >
   > Lots of terminal applications handle  some characters specially: in particular
   > when you hit your enter key it sends a newline.
   > Most shells will execute the contents of the input buffer at that point, which
   > is usually what you want.
   > Unfortunately, this  means that they will  also run the contents  of the input
   > buffer if there's a newline in anything you paste into the terminal.
   >
   > [...]

   > For a while I've been running with  bracketed paste mode enabled to protect me
   > from myself [...].

##
# I've changed the value of the `cbt` and `kcbt` capabilities.

    $ tic -sx <(infocmp -x | sed 's/cbt=\\E\[Z/cbt=\\E\[Y/g')

## Why is the new value not printed when I press `C-v S-Tab`?

Only  screen-oriented  programs   use  terminfo.   Your  terminal   is  *not*  a
screen-oriented program,  and it doesn't need  to query an external  database to
know which sequence it should emit when S-Tab is pressed.

##
# Reference

[1]: https://cirw.in/blog/bracketed-paste
[2]: https://unix.stackexchange.com/a/230784/289772
