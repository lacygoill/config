# tmux-fingers
## It doesn't work at all!

Run this script to check everything is properly configured:

    $ ~/.config/tmux/plugins/tmux-fingers/scripts/health-check.sh

In particular, make sure you've initialized the plugin's submodules:

    $ cd ~/.config/tmux/plugins/tmux-fingers
    $ git submodule update --init --recursive

## It doesn't let me search outside the current screen!

Use our `M-c` key binding, which writes the whole scrollback buffer in a Vim buffer.

## Sometimes it fails!

MRE: Press `pfx ?`, then `pfx f`.

I don't know how to fix this atm.

##
## Why should I avoid installing tmux-copycat?

First, it installs a bunch of key bindings which are hard to remember.

Besides, it's buggy:

   - it can be [slow][1]
   - remapping the Escape key in copy mode may [break][2] the plugin
   - after you use one of its key bindings, it may override and break some of yours

---

When you press a key binding from copycat, this line overrides some key bindings:

    # Source: ~/.tmux/plugins/tmux-copycat/scripts/copycat_mode_bindings.sh:42
    extend_key "$key" "$CURRENT_DIR/copycat_mode_quit.sh"

This is because `Y` is in the output of `copycat_quit_copy_mode_keys()` which is defined here:

    tmux-copycat/scripts/helpers.sh

The latter runs:

    tmux list-keys -T copy-mode-vi |
            \grep cancel |
            gawk '{ print $4 }' |
            sort --unique |
            sed 's/C-j//g' |
            xargs echo

Basically, it finds any LHS of key binding whose RHS contains the pattern `cancel`.
And our current `Y` key binding *does* contain `cancel`:

    bind -T copy-mode-vi Y send -X copy-selection-and-cancel \; paste-buffer -p
                                                      ^----^

---

Here's a command equivalent to what the plugin does with our original `Y` key binding:

    $ tmux bind -T copy-mode-vi Y run "tmux send -X copy-selection-and-cancel \
        ; paste-buffer -p \
        ; ~/.tmux/plugins/tmux-copycat/scripts/copycat_mode_quit.sh \
        ; true"

It's broken, because:

   1. the original RHS contained a semicolon
   2. the new RHS runs a shell command, where the semicolon has a special meaning
   3. a semicolon is special for the shell, and so needs to be escaped
   4. the plugin doesn't take care of escaping a semicolon from the original key binding

If you  remove everything after  `paste-buffer -p`, you  can see that  the shell
exits with  the error  code 127, because  it tried to  run `$  paste-buffer` and
didn't find it in `$PATH`.

    $ tmux bind -T copy-mode-vi Y run "tmux send -X copy-selection-and-cancel ; paste-buffer -p"
    # press pfx Y in copy-mode
    'tmux send -X copy-selection-and-cancel ; paste-buffer -p' returned 127˜

##
# Reference

[1]: https://github.com/tmux-plugins/tmux-copycat/issues/129
[2]: https://github.com/tmux-plugins/tmux-copycat/blob/master/docs/limitations.md
