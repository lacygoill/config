# How to limit the bandwidth?

Look for the keyword “limit” at `man transmission-remote(1)`.
Also, look at the examples at the bottom of the same man page.

Whatever info you find, turn it into a shell snippet.

# Build a TUI for transmission?

Using `dialog(1)` or `whiptail(1)`.

Interesting link:
<https://ostechnix.com/create-gui-dialog-boxes-in-bash-scripts-with-whiptail/>

Interesting examples:

    /usr/share/doc/dialog/examples/

Not all the files are executable (i.e. meant to be executed).

To test an example:

    $ cd /usr/share/doc/dialog/examples/
    $ ./password

To edit an example:

    $ sed '
        1a cd /usr/share/doc/dialog/examples
        /^$DIALOG/ s//$DIALOG --insecure/
    ' /usr/share/doc/dialog/examples/password >/tmp/sh.sh
    $ chmod u+x /tmp/sh.sh
    $ /tmp/sh.sh

---

More generally, should  we build TUIs for groups of  related commands taken from
our shell snippets?

#
# Watch and document this playlist:

<https://www.youtube.com/watch?v=ee4XzWuapsE&list=PLqv94xWU9zZ05Dbc551z14Eerj2xPWyVt>

We  need  a bunch  of  shell  aliases/functions  to  make the  interaction  with
transmission easier.  The first video has some good info for that.

---

And this video:
<https://www.youtube.com/watch?v=0uXFffq-UPU>
*torsocks - Access The Tor Network*

#
# review torrentflix

<https://github.com/ItzBlitz98/torrentflix/>

Pros:

   - can download subtitles automatically
   - can stream
   - Trakt.tv integration

Trakt.tv seems  to be some  kind of  social website dedicated  to movies/series,
which could be useful to discover things to watch.
How good is it though?
How does it compare to these alternatives?:

   - <https://followmy.tv/>
   - <https://simkl.com/>

Are there better alternatives?

Cons:

   - require nodejs
   - require peerflix
   - pull many dependencies
   - does too much?  too complex?
   - only streaming?  no persistent download?

Edit: All those cons are not warranted.
However, peerflix and torrentflix are not real alternatives to `we-get`.
They are more an alternative to stremio (minus the catalogue and the posters).

# review bitsearch.to

<https://bitsearch.to/>

# How to install stremio?

Download a `.deb` from here:
<https://www.stremio.com/downloads>

Install the deb like this:

    $ sudo apt install ./stremio*.deb

But not like this:

    $ sudo dpkg -i stremio*.deb

The latter would not automatically install any missing dependency.
The former will.

---

Document how to install the torrentio plugin/addon.

##
# Document these tools
## ani-cli

<https://github.com/pystardust/ani-cli>

A CLI to browse and watch anime.  This tool scrapes the site gogoanime.

## mpv-autosub

<https://github.com/davidde/mpv-autosub>

Automatic subtitle downloading for MPV

## ytfzf

<https://github.com/pystardust/ytfzf>

A  POSIX  script   that  helps  you  find  Youtube  videos   (without  API)  and
opens/downloads them using mpv/yt-dlp.

Try to use kitty as a thumbnail viewer, instead of w3m:
<https://github.com/pystardust/ytfzf#Alternative-Thumbnail-Viewers>

#
# Find a way to access Z-Library

ATM, you need to create an account: <https://singlelogin.re>

See also: <https://old.reddit.com/r/zlibrary/comments/zx6z62/megathread_how_to_access_zlibrary_on_tor_app/>

---

Z-Library *might* have books which you can't find on Library Genesis.
Note that  Anna's Archive scrapes  both sites, so even  if you can't  download a
file from Z-Library, you can still check  whether it has the book you're looking
for.
