# understand why fzf can't match text in a description beyond a certain column (97 ATM)

That doesn't happen when we call fzf manually:

    $ echo 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx abc' | fzf
    # insert query: abc

The input query `abc` is correctly matched, even though it's beyond the 100th column.

# find a way to trim a trailing comment in the preview window when providing a value for an argument

    finder:
      ...
      overrides_var: >-
        ...
        --preview='???'

To keep  the default formatting  and highlighting  performed by navi,  you first
need to find  out which shell code  does navi pass to the  `--preview` option of
fzf when providing a value for an argument.   Then, you could pipe the code to a
`sed(1)` command to trim a trailing comment.

When selecting a snippet, navi uses this shell code (found with `strace(1)`):

    navi preview {}

And when providing an argument value, navi uses some shell code which boils down
to this:

    navi preview-var '{+}' '{q}' 'argument_placeholder'
                      ^^^   ^^^
           selected value   currently typed query

The issue  is that we don't  have any way  to refer to the  argument placeholder
from our navi config.  Do we?

---

BTW, the `preview` and `preview-var` commands  of navi are not documented in its
`--help`.  Should they?

They are somewhat documented if you run these commands:

    $ navi preview
    error: the following required arguments were not provided:
      <LINE>

    Usage: navi preview <LINE>

    For more information, try '--help'.

    $ navi preview-var
    error: the following required arguments were not provided:
      <SELECTION>
      <QUERY>
      <VARIABLE>

    Usage: navi preview-var <SELECTION> <QUERY> <VARIABLE>

    For more information, try '--help'.

But that doesn't make them discoverable.
Besides, the  user might infer  from the last  message that `--help`  gives more
information about these subcommands.  It does not.

# find a way to generate dynamic arguments

For example, in `~/.config/navi/snippets/terminal.cheat`:

    $ script_cmd: printf '%s\n' 'Record current interactive shell session?' yes no \
        --- --header-lines 1 \
            --map "\
                case $(cat) in \
                    yes) ;; \
                    no) printf -- '--command=\"some command\"' ;; \
                esac \
            "

It would be nice to be able to replace `some command` with `<cmd>` and make navi
prompt us for the desired command.

# try to make navi remember the preview window layout across arguments of the same snippet

If we press a custom key binding to change the layout for a given argument, it's
unexpected for navi to reset the layout  when prompting us for the next argument
of the same snippet.

# maybe report on the navi issue tracker that `;` is a poor choice for the meta comment leader

Because it  makes `;`  ambiguous: it  can be  a comment  leader or  a separation
between 2 shell commands.

Worse, this ambiguity is resolved in a non-obvious way.
`;` is only parsed as a meta comment leader if it's right at the start of the line:

    # some comment
    echo some command
    ; this is a meta comment
    ^

    # some comment
    echo some command \
     ; echo this is not a meta comment
    ^^

navi had  a similar  issue when  it had  to find  a syntax  to separate  a shell
command producing default values for an argument, from optional parameters.

It chose `---`. I  think the rationale is that it extends  the `--` syntax which
is a widely used convention among a lof of linux commands.

Why not doing the same with `#`, which  is widely used as a comment leader (navi
itself uses it for the command descriptions)?
We could use `##` for meta-comments, and maybe keep `;` as a legacy syntax.

---

Note that `;` is annoying in Vim when we break a long command:

    command A; command B; command C
             ^          ^
             in a `.cheat` file, press `g Space` on these semicolons to break the command

The end purpose is to get this:

    command A \
        ; command B \
        ; command C

But when pressing `g Space` the second time, an extra semicolon is unexpectedly inserted:

    command A
    ; command B
    ; ; command C
      ^
      ✘

It could  be avoided by temporarily  resetting `'comments'` from `:;`  to `f:;`,
but this is too cumbersome.  Anyway, this highlights the fact that `;` is a poor
choice.

# document more advanced variable options

When defining the default values of an argument, these parameters are supported:

    ┌───────────────────────┬───────────────────────────────────────────────────────┐
    │ --column <number>     │ extracts a single column from the selected result     │
    ├───────────────────────┼───────────────────────────────────────────────────────┤
    │ --expand              │ converts each line into a separate argument           │
    ├───────────────────────┼───────────────────────────────────────────────────────┤
    │ --fzf-overrides <arg> │ applies arbitrary fzf overrides                       │
    ├───────────────────────┼───────────────────────────────────────────────────────┤
    │ --map <bash_code>     │ applies a map function to the selected variable value │
    ├───────────────────────┼───────────────────────────────────────────────────────┤
    │ --prevent-extra       │ limits the user to select one of the suggestions      │
    └───────────────────────┴───────────────────────────────────────────────────────┘

They must be separated from the shell command generating the values by a `---`.

In addition, it's possible to forward the following parameters to fzf:

    --delimiter <regex>
    --filter <text>
    --header <text>
    --header-lines <number>
    --multi
    --preview <bash_code>
    --preview-window <text>
    --query <text>

Source: <https://github.com/denisidoro/navi/blob/master/docs/cheatsheet_syntax.md#advanced-variable-options>

# document how we can refer to a previous argument inside an argument definition

    $ arg1: ...
    $ arg2: ... $arg1 ...
                ^---^

Also, logical operators such as `&&` can  be used to write an inline conditional
transformation:

    $ arg2: ... $([[ $arg1 =~ some_pattern ]] && printf 'arg1 transformed' ) ...
                ^----------------------------------------------------------^
                  transform arg1 if, and only if, it matches some pattern

# document `--prevent-interpolation`

<https://github.com/denisidoro/navi/commit/e3920552ca99bd3f436f548ffdbef7621f7b079d>

ATM, it's not documented in the repo's docs, but it is briefly mentioned in the `--help`:

    $ navi --help | grep --after-context=1 -- '--prevent-interpolation'
    --prevent-interpolation
        Prevents variable interpolation

# cache some of the shell commands called to provide the default values of some arguments

For example:

    $ MIME_type: grep --recursive MimeType $(locate '*.desktop') \
        | sed 's/.*:MimeType=\(.*\)/\1/ ; s/;/\n/g' \
        | sed '/^$/d' \
        | sort --unique

That's too costly to be run every single time we need a mimetype snippet.

Try to install a systemd timer to cache the output in a file under `~/.cache/navi/`.

# submit a man page, pdf, epub, html files in a PR?

See “Appendix A. Writing Manual Pages” in the “Classic Shell Scripting” book.

Or, try to convert the markdown files from the original repo under `docs/` into a man page:
<https://www.pragmaticlinux.com/2021/01/create-a-man-page-for-your-own-program-or-script-with-pandoc/>
