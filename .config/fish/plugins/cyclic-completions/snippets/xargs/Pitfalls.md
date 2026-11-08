# My command complains about an invalid option!

Maybe an  input line starts  with a  hyphen; that can  break your command  if it
wrongly parses that as one of its options:

    $ cd /tmp
    $ echo text >-l

    $ echo -l | xargs cat
    cat: invalid option -- 'l'

Try to use the `--` syntax to signal the end of the command's options:

                          vv
    $ echo -l | xargs cat --
    text

Beware that not all commands support `--`; e.g. `xdg-open(1)` does not.
