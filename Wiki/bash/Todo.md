# learn factoids from greybot (bot on irc channel `#bash` on libera)

            │ !greybot
    greybot │ I'm a bot. I'm written in perl. My source, factoids, and stats are at http://wooledge.org/~greybot/
            │ See !help for a list of my commands. git mirror https://github.com/im14/greybot

You can find all the factoids here: <http://wooledge.org/~greybot/meta/>
In each factoid, you'll often find the commands `learn` and `forget`.
I think that `learn` make the bot register a factoid, while `forget` unregister it.
Anyway, always read the last `learn` command, because all the previous ones are outdated.

# document the meaning of "options", "option-arguments", and "operands"

<https://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html#tag_12_01>

##
# in tests, replace `-f` with `-s` whenever it makes sense

Sometimes, you  might want to  test whether a  file contains something,  and not
just whether it exists.

    :ConfigGrep -filetype=bash \<if\>.* -f \C

# refactor all our scripts so that they leverage systemd to log their activity

Either make them use `systemd-cat(1)`:

    $ systemd-cat --identifier=myscript --priority=info echo 'some message'

Or try something more involved: <https://serverfault.com/a/1040601>

---

Edit: should we replace `systemd-cat(1)` with `logger(1)` everywhere?

   > **I would stick with logger**: it works with any standards-compliant logging system,
   > including systemd’s journal as you’ve discovered. Using systemd-cat directly
   > would  only make  your  scripts systemd-specific,  without  adding anything;  in
   > fact,  modern logger  is **much  more flexible**,  and provides  **better support  for**
   > **systemd-specific features than systemd-cat itself**.

Source: <https://unix.stackexchange.com/a/393102>

##
# study `~/.fzf/bin/fzf-tmux`

Useful to learn how `mkfifo(1)` can be useful.
Also useful to learn more about `fzf(1)` and `tmux(1)`.
