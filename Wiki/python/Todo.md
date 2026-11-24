# Read these generic documents about Python

- <https://docs.python.org/3/tutorial/>
- <https://docs.python.org/3/faq/programming.html>
- <https://docs.python.org/3/howto/index.html>
- <https://docs.python.org/3/glossary.html>

##
# Learn these tools, and integrate them in our workflow
## black

Installation:

    $ pipx install black

---

<https://github.com/psf/black>
<https://black.readthedocs.io/en/stable/usage_and_configuration/index.html>

When configuring `black`, you'll often need to choose a style over another.
Which implies that you need to know the pros and cons of each choice.
Read these style guides as references:
- <https://peps.python.org/pep-0008/>
- <https://google.github.io/styleguide/pyguide.html>

## pylint

Read this: <https://pylint.pycqa.org/en/latest/tutorial.html>
As well as the following user guide.

This command populates a default config file for `pylint`:

    $ pylint --generate-rcfile >>~/.pylintrc

Also, take inspiration from this config file from Google:
<https://google.github.io/styleguide/pyguide.html#21-lint>

---

Should we use flake8 instead?
That's the linter recommended by the "Learn Python Programming" book.
Is it easier to use?  faster?
It seems better maintained (much fewer open issues on GitHub).

- <https://github.com/PyCQA/flake8>
- <https://flake8.pycqa.org/en/latest/index.html>

## mypy

<https://mypy.readthedocs.io/en/stable/getting_started.html>

## textual

<https://github.com/Textualize/textual>

##
## pudb

`pdb` is a module which is built by default into the python interpreter.
`pudb` is a TUI front-end for `pdb`.
To install the latter:

    $ pipx install pudb

- <https://www.youtube.com/watch?v=bJYkCWPs_UU>
- <https://documen.tician.de/pudb/#table-of-contents>
- <https://realpython.com/python-debugging-pdb/>

---

Here is an example of command that you can run to debug `tldr` without having to
modify the script:

    $ pudb $(which tldr)

### create a README file

    ~/.config/pudb/README

And version control its contents.

### finish customizing its color theme

    ~/.config/pudb/theme.py

### write a `.cheat` or `cheatkeys` file

Key bindings:

    ? = Help Menu
    C-P = Edit Preferences

Configuration settings are saved in `~/.config/pudb`.

Note  that  some keys  can  interact  with  the  command-line window  (e.g.  `+`
increases  its height),  but  only  if you  focus  its  `<Clear>` button  (press
`Right`).

##
# Customizations
## customize conky to add a weather indicator

<https://github.com/edusig/conky-weather>

## customize the tab bar in kitty

    ~/.config/kitty/tab_bar.py

There  is  a whole  bunch  of  code which  we  don't  understand yet  in  there.
Also,  the comments  need  to be  trimmed  down,  and moved  into  Vim or  shell
snippets/`cheatkeys` files/notes...

##
# Assimilation
## understand the code in `yt-dlp-comments-prettifier`

    ~/bin/yt-dlp-comments-prettifier

## various Python programs which we use (we could rewrite some of them)

interSubs:

    # 1370 sloc
    ~/.config/mpv/scripts/interSubs.disable/interSubs.py

    # 57 sloc
    ~/.config/mpv/scripts/interSubs.disable/interSubs_config.py

---

subliminal:

    ~/.local/bin/subliminal
    ~/.local/pipx/venvs/subliminal/lib/python3.8/site-packages/subliminal/

##
# Document
## how `$ python3 -m pip` finds the pip module

I think it looks  for a `pip/` directory under a  directory of `sys.path`, whose
value is built programmatically:

    $ python3 -m site
    sys.path = [
        '/home/lgc/Wiki/python',
        '/usr/lib/python38.zip',
        '/usr/lib/python3.8',
        '/usr/lib/python3.8/lib-dynload',
        '/home/lgc/.local/lib/python3.8/site-packages',
        '/usr/local/lib/python3.8/dist-packages',
        '/usr/lib/python3/dist-packages',
    ]
    USER_BASE: '/home/lgc/.local' (exists)
    USER_SITE: '/home/lgc/.local/lib/python3.8/site-packages' (exists)
    ENABLE_USER_SITE: True

See: <https://docs.python.org/3/library/sys_path_init.html#the-initialization-of-the-sys-path-module-search-path>

For example, on our current machine,  Python finds the pip module because thanks
to this directory:

    ~/.local/lib/python3.8/site-packages/pip/

##
# Refactoring
## In type annotations, replace `Dict` with `dict` (and `List` with `list`).

But only once you switch to Python >=3.9:

   > In type annotations  you can now use built-in collection  types such as list
   > and dict as generic types instead of importing the corresponding capitalized
   > types (e.g. List or Dict) from typing.

Source: <https://docs.python.org/3/whatsnew/3.9.html#type-hinting-generics-in-standard-collections>

For example:

    # no longer necessary; remove it
    # v-------------------v
    from typing import Dict

    #       replace with `dict`
    #       v--v
    result: Dict[str, int] = {
        'priority': -1,
        'count': -1,
        'bufnr': -1
    }
