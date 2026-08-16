# Add support for hex colors in an OSC 12 sequence

When we change the cursor color from Vim (`coC`), it would be nice to be able to
use `#ab1234` or `rgb:ab/12/34`.

---

Also, try  to make Vim  read read the current  cursor color from  the terminal's
config:

   - `~/.Xresources`, /cursorColor
   - `~/.config/st/patches/01_custom_config.diff`, /defaultcs

And save it in a Vim global variable as soon as we start Vim.
Finally, make `toggle_settings.vim` use this  color when change the color scheme
back to its original state.

All of this would fix the following issue:
when we change the  color scheme, then get back to the  original one, the cursor
color is not properly restored.

# Implement OSC 112 to be able to restore the default cursor color

We don't really need this, but maybe it could be useful in the future.

See `~/.config/st/patches/99_osc_12.diff` for inspiration.
And this [reddit thread][6].

Once  you've implemented  it, update  your tmux.conf  to set  the `Cr`  terminfo
extension *un*conditionally:

    set -as terminal-overrides ',*:Cs=\E]12;%p1%s\007'
    if-shell '[ "$TERM" != "st-256color" ]' 'set -as terminal-overrides ",*:Cr=\\E]112\\007"' ''

    →

    set -as terminal-overrides ',*:Cs=\E]12;%p1%s\007:Cr=\E]112\007'

#
# Read the FAQ

<https://git.suckless.org/st/file/FAQ.html>

# Read the arch wiki

<https://wiki.archlinux.org/index.php/St>

# Watch this video

<https://www.youtube.com/watch?v=9H75enWM22k>

# Prevent `make(1)` from compiling the terminfo description into our local database.

I don't trust it.
I prefer to rely on the one from invisible-island.

    $ curl -L -O http://invisible-island.net/datafiles/current/terminfo.src.gz
    $ gzip --decompress terminfo.src.gz
    $ tic -s -x terminfo.src

Note somewhere that we should remove these lines:

    tic -sx st.info
    @echo Please see the README file regarding the terminfo entry of st.

... from `~/VCS/st/Makefile`.

This should be done automatically (with `sed(1)`), so we need to use a script.
Maybe use `upp`.

---

Why don't you trust this terminfo description?

When you look at the terminfo.src from invisible-island, you can read this:

   > Se and Ss are implemented in the source-code, but the terminfo
   > provided with the source is incorrect, since Se/Ss are mis-coded
   > as booleans rather than strings.

...

   > The source includes two entries which are not useful here:
   >       st-meta| simpleterm with meta key,
   >       st-meta-256color| simpleterm with meta key and 256 colors,
   > because st's notion of "meta" does not correspond to the terminfo definition.
   > Rather, it acts like xterm - when the meta feature is disabled.

It seems to indicate that the  terminfo description which comes with st's source
code is  not always correct... Search  for `\C\<st\>` in terminfo.src,  and read
the few reviews that you find.

---

After reading this: <https://github.com/tmux/tmux/issues/1264>
I wonder whether we should stick with the terminfo description from st source code.

And if you read this:
<https://github.com/tmux/tmux/issues/1593#issuecomment-460063051>
You may, yet again, change your mind:
   > The upstream st (which I've seen more than once comment suggesting as an improvement) also is incorrect.

---

Also, if you write a script to install st, make sure it runs `$ make clean`.
<https://github.com/tmux/tmux/issues/1264#issuecomment-397909842>

# join the irc `#suckless` channel

It would be useful to gather some useful tips/information organically over time.

- <https://suckless.org/community/>
- <https://www.oftc.net/>

This requires that you register your nick on the OFTC network.
