# Installation

Download a pre-compiled binary:

   - <https://github.com/denisidoro/navi/blob/master/docs/installation.md#downloading-pre-compiled-binaries>
   - <https://github.com/denisidoro/navi/releases/latest>

And move it to a directory in your `$PATH`.

---

Or compile from source:

    $ git clone https://github.com/denisidoro/navi
    $ cd navi
    $ make install

    # (optional) to set the install directory:
    # make BIN_DIR=/usr/local/bin install

Source: <https://github.com/denisidoro/navi/blob/master/docs/installation.md#building-from-source>

##
# Syntax
## A `%` directive limits the scope of 3 things.  Which ones?

   - the tag names (on the same line as `%`):
     they can only tag the snippets which come afterward,
     and before the next `%` directive (if any)

   - the argument values defined with a `$` directive:

   - the argument values defined with an `@` directive

### What are its boundaries?

It starts from a `%` line, and ends right  before the next one, or at the end of
the file.

This implies that:

   - a single file can contain several categories of shell snippets (each
     identified by a unique list of tags)

   - if it does, you might need to re-write an `@` directive several times;
     once per `%` directive

##
## We can specify the matches that fzf should give for an argument value with some shell code.

    % some_tag
    # some description
    echo 'aaa <some_arg> bbb'
    $ some_arg: printf 'test'

### How to share it across different lists of tags?

Import it with an `@` directive:

    % another_tag
    # another description
    echo 'ccc <some_arg> ddd'
    @ some_tag
    ^--------^

When choosing the  `# another description` snippet, and fzf  prompts you for the
value of `<some_arg>`, `test` is suggested thanks to the `@` directive.

---

   > With  the `@  same tags  from other cheatsheet`  syntax you  can reuse  the same
   > variable in multiple cheatsheets.

Source:
<https://github.com/denisidoro/navi/blob/master/docs/cheatsheet_syntax.md#extending-cheatsheets>

##
# Miscellaneous
## Where can I find more shell snippets?

Look for shell snippets from the online `cheat.sh` repository:

    $ navi --cheatsh=<query> --print

`cheat.sh`  is a  special  website which  is  intended to  be  queried from  the
command-line via `curl(1)`.

---

Also, look for shell snippets from the online tldr-pages repository:

    $ navi --tldr=<query> --print

`--tldr` makes navi start the tldr binary, and pass it the `--markdown` option.
For a given query, the first invocation can be a bit slow, because pages need to
be downloaded  from the web.   But they are  cached in `~/.cache/tldr/`,  so the
next invocations are quicker.

### How to query a local version of the `cheat.sh` website?

Install a local copy via the `cht.sh` script:

    $ curl https://cht.sh/:cht.sh >~/bin/cht.sh
    $ chmod u+x ~/bin/cht.sh

    # the virtualenv package is needed to install cheat.sh in the standalone mode
    $ sudo apt-get install virtualenv

    # warning: this takes a few minutes
    $ cht.sh --standalone-install ~/.local/share/cheat.sh
    Where should cheat.sh be installed [/home/lgc/.local/share/cheat.sh]?˜
    ...˜
          _˜
         \ \        The installation is successfully finished.˜
          \ \˜
          / /       Now you can use cheat.sh in the standalone mode,˜
         /_/        or you can start your own cheat.sh server.˜


    Now the cht.sh shell client is switched to the auto mode, where it uses˜
    the local cheat.sh installation if possible.˜
    You can switch the mode with the --mode switch:˜

        cht.sh --mode lite      # use https://cheat.sh/ only˜
        cht.sh --mode auto      # use local installation˜

    You can add your own cheat sheets repository (config is in `etc/config.yaml`),˜
    or create new cheat sheets adapters (in `lib/adapters`).˜

    To update local copies of cheat sheets repositores on a regular basis,˜
    add the following line to your user crontab (crontab -e):˜

        10 * * * * /home/lgc/.local/share/cheat.sh/ve/bin/python /home/lgc/.local/share/cheat.sh/lib/fetch.py update-all˜

    All cheat sheets will be automatically actualized each hour.˜

    If you are running a server reachable from the Internet, it can be instantly˜
    notified via a HTTP request about any cheat sheets changes. For that, please˜
    open an issue on the cheat.sh project repository [github.com/chubin/cheat.sh]˜
    with the ENTRY-POINT from the URL https://ENTRY-POINT/:actualize specified˜

### Where can I can find more info about `cheat.sh`?

   - <https://github.com/chubin/cheat.sh#usage>
   - <https://github.com/chubin/cheat.sh#self-hosting>
   - <https://github.com/chubin/cheat.sh/blob/master/doc/standalone.md#cheatsh-server-mode>

##
# Reference

[1]: https://github.com/lotabout/skim
