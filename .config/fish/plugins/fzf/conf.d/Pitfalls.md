# fzf completes what I wrote on its prompt.  I don't want any completion!

Do *not* press Enter:

    $ echo '123' | fzf
    # press: 1 Enter
    123

Instead, press `C-g`:

    $ echo '123' | fzf
    # press: 1 C-g
    1

This works because by default we've bound `C-g` to `print-query`.
The latter is documented at `man fzf /KEY/EVENT BINDINGS/;/AVAILABLE ACTIONS:/;/print-query`:

   > print-query                (print query and exit)

# I call fzf to change the command-line.  Sometimes, it's entirely cleared!

Make sure to repaint it right after calling fzf:

    commandline --function repaint

It's necessary if you don't select an entry, and cancel by pressing Escape.
