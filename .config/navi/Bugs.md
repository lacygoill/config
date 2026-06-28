# The preview is sometimes wrong!

    $ var: printf 'a\nb' --- --multi --map 'cat | paste --serial --delimiters=","'

    # some comment
    echo <var>

Select `a` and `b`.

Expected: The preview displays this:

    var = a,b

Actual: The preview displays this:

    var = a' 'b

# I can't accept the current query!

In `$FZF_DEFAULT_OPTS`, we bind `C-g` to the `print-query` action:

    --bind=ctrl-g:print-query

This lets us accept the current query without completing it.
This can be useful if we want to insert a query as-is, while navi prompts us for
an argument value:

    # press: C-g C-g
    # insert: trans del  (to select the shell snippet which deletes a torrent:)
    # press: Enter
    # insert: 1
    # press: C-g  (to insert 1 as the torrent ID)

Unfortunately, it doesn't work.

Actual:

    $ transmission-remote --torrent= --remove-and-delete
                                    ^
                                    ✘

Expected:

    $ transmission-remote --torrent=1 --remove-and-delete
                                    ^
                                    ✔


In `~/.config/navi/config.yaml`, I've tried to replace this line:

    overrides_var: --height=52%

With this one:

    overrides_var: --bind=ctrl-z:print-query

Then, I've pressed `C-z` instead of `C-g`.  Same result.

---

For the moment, the solution is to press `Tab`.
This is documented here:

   > If you hit <tab> the query typed will be prefered.
   > If you hit <enter> the selection will be prefered.

Source: <https://github.com/denisidoro/navi/blob/master/docs/cheatsheet_syntax.md#variables>

But it's  still an issue  because it's inconsistent  with invocations of  fzf in
different contexts.

Besides, without any fzf config, fzf binds `Tab` to `toggle+down`.
This could  be a  valid usage  even when  navi starts  fzf to  let us  select an
argument value.  It doesn't seem right for navi to override this.

# I can't use `=` between the `--header` option and its operand argument!

In `~/.config/navi/snippets/admin.cheat`, we can't write this at the top of the file:

    $ cmd: --- --header=test
                       ^
                       ✘

For some reason, it causes all shell snippets from `admin.cheat` to be ignored.
We need to remove the `=`:

    $ cmd: --- --header test
                       ^
                       ✔

But for `fzf(1)`, this `=` is valid:

    $ ls | fzf --header=test

What gives?

---

The exact same issue applies to `--header-lines`.

# I can't write `$(cat)` several times in an argument definition!

    $ arg: echo 'a' \
        --- --map "\
                case $(cat) in \
                    a) printf '%s' $(cat) ;; \
                    *) ;; \
                esac \
            "

    # some comment
    echo <arg>

Expected: After pressing Enter to select the `a` value, the command-line is `echo a`.
Actual: The command-line is `echo`.

Workaround: Use a temporary file:

    $ arg: echo 'a' \
        --- --map "\
                cat >/tmp/.navi \
              ; case $(< /tmp/.navi) in \
                    a) printf '%s' $(< /tmp/.navi) ;; \
                    *) ;; \
                esac \
              ; rm /tmp/.navi \
            "

    # some comment
    echo <arg>

Ideally, we should be able to give the  name of a navi function to `--map`.  The
latter  would receive  the selected  value as  argument, and  should output  its
transformation.  Not sure in which language  this navi function would be written
(Python, Lua, ...).

    $ arg: echo 'a' --- --map NaviFunc
                              ^------^

# I've selected multiple values for a given argument (`--multi`).  They're printed on multiple lines!

So, instead of something like this:

    $ transmission-remote --torrent=1
      2
      3 --stop

You want something like this:

    $ transmission-remote --torrent=1,2,3 --stop
                                    ^---^
                                      ✔

Use a `--map` parameter to invoke `paste(1)` like this:

    --map 'paste --serial --delimiters=","' \
    --multi

Note that  you can't  use `--map` twice;  the last one  would overwrite  all the
other ones.  So, if the definition of your argument value already uses a `--map`
parameter:

    --map 'sed -E "s/[^0-9]*([0-9]+).*/\1/"' \
    --multi

then you need to combine the two in a pipeline:

    --map 'sed -E "s/[^0-9]*([0-9]+).*/\1/" | paste --serial --delimiters=","' \
    --multi

---

`--expand` should  take care  of that  issue, but it  doesn't work  with `--map`
because of a bug: <https://github.com/denisidoro/navi/issues/708>

# When I'm prompted for an argument value, and I press Enter without giving one, an empty line is added!

Yes, and it pushes the next lines out of view:

    argument1 =
    argument2 =
    argument3 =

    →

    argument1 =

    argument3 =

I guess it's a bug, but it should not happen in practice.
You will probably always give a value to an argument.
