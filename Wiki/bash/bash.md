# Why should I always declare a function variable as local?

First, without `local`, a variable is global by default:
```bash
var='global'
function A {
  var='local to function A'
}
echo "$var"
A
echo "$var"
```
    global
    local to function A

Notice that `var` was reset in the global namespace after `A` was called.

Second, during a function call, a caller and a callee share their variables.  As
a result, a callee can alter the value  of a variable used by its caller, giving
unexpected results:
```bash
function A {
  local -i i
  for (( i = 0; i < 2; i++ )); do
    B
  done
}
function B {
  for (( i = 0; i < 3; i++ )); do
    echo "$i"
  done
}
A
```
    0
    1
    2

This code outputs `0`,  `1`, and `2` only once even though  `B` should have been
called twice.  That's because, during its first  call, `B` has set `i` to `3` in
`A`'s execution  environment, which  prevents `A` from  iterating one  more time
(`i < 2` fails).  To fix the issue, you need to make `B`'s variable local:
```bash
function A {
  local -i i
  for (( i = 0; i < 2; i++ )); do
    B
  done
}
function B {
  # make sure `B` does not reset `i` in a caller's execution environment
  local -i i
  for (( i = 0; i < 3; i++ )); do
    echo "$i"
  done
}
A
```
    0
    1
    2
    0
    1
    2

# Why can I write a lone `[[ expression ]]` in a utility function used to test something?

It works (without `return`),  because the exit status of a  user function is the
exit status of the last command executed in its body:
`man bash /SHELL GRAMMAR/;/Shell Function Definitions/;/status`

    function myfunc {
      [[ expression ]]
    }

    if myfunc; then
      ...
    fi

# What are the rules to know with regard to redirections?

   - In `A | B`, redirections to the pipe are processed before A's redirections.

   - In `{ A; } B`, B's redirections are processed before A's redirections; as
     a consequence,  the commands  inside  `A` inherit  the redirections  done
     from B.

   - Otherwise, redirections are processed from left to right.

Finally, `&N` refers to the file to  which the fd `N` is connected *at the time*
of processing.

For example,  if fd  3 is  connected to  the file  `foo`, at  the time  `>&3` is
processed, it doesn't matter whether it's later re-connected to `bar` (e.g. with
`3>bar`); `>&3` will write to `foo` no matter what:

    $ cmd 3>foo >&3 3>bar
                 ^^
                 foo

---

    $ ls /tmp /foo 2>&1 >file

This command  writes STDERR on  the terminal,  and STDOUT into  `file`.  Indeed,
when `2>&1` is processed, fd 1 is connected to the terminal.

    $ ls /tmp /foo 2>&1 >file | less

This command sends STDERR to `less(1)`, and writes STDOUT into `file`.

Indeed, `>file` is processed after `|`, and so has the last word on where STDOUT
goes.  And, when `2>&1` is processed, fd 1  is connected to the pipe, so fd 2 is
too.

    $ ls /tmp /foo >file 2>&1 | less

This command  writes both  STDOUT and  STDERR into  `file`.  Initially,  all the
streams are redirected to the pipe, but then they are successively redirected to
`file`.

# Why does a non-exported shell variable persist in a subshell but not in a script?

It can survive after `fork(2)`:

    #              forked subshell
    #              v           v
    $ var='value'; (echo "$var")
    value

But not after `execve(2)`:

                   v--v
    $ var='value'; exec bash
    $ printf '|%s|\n' "$var"
    ||

---

When you run  `./script`, bash `fork(2)`s a subshell which  then `execve(2)` the
shebang (`/bin/bash`) to run the script:

    /bin/bash /path/to/script

Internal aspects of the subshell are lost in the `execve(2)` call.  Non-exported
variables, functions, aliases ... are bash  notions that the kernel doesn't know
about; they're  lost when  bash executes  another program.   Even if  that other
program happens  to be  the same  (i.e. `/bin/bash`),  it is  executed by  a new
process that doesn't know or care that its parent happens to also be an instance
of the same shell.

##
# In which order are the various kinds of expansion performed?

   1. brace expansion
   2. tilde expansion
   3. parameter and variable expansion
   4. command substitution
   5. arithmetic expansion
   6. word splitting
   7. pathname expansion

Process substitution  is performed at  the same time  as `2.`, `3.`, `4.`, `5.`.
This means  that process substitution  can be performed  before or after  any of
them.  This lets you write a process substitution inside `2.`, `3.`, `4.`, `5.`,
as well as write `2.`,  `3.`, `4.`, `5.` inside a process substitution.

For more info: `man bash /^EXPANSION`.

# How to disable a builtin command to use the external command which is its counterpart?

    $ enable -n printf

You can check the effect by executing `$ type printf` before and after the command.

##
# When does the shell fork a subshell?

To execute:

   - ( list )
   - a job
   - a command substitution
   - a process substitution
   - a simple command in a pipeline

You can confirm that a job is executed in a subshell with these commands:

    $ { sleep 1000; echo finished ;} &
    $ pstree --long --show-parents --show-pids $(pidof -s sleep)
    ... bash───bash───sleep
               ^--^
              subshell

# Why does a shell fork to execute an external command?

After invoking  `execve()`, the shell  process has  replaced its image  with the
image of an external command.
So, if the shell didn't fork, `execve()` would in effect “kill” the shell.
It would have no way to print another  prompt, and go on doing its job after the
external command has finished.

# Does a subshell always fork to execute an external command?

No.

A subshell doesn't need to fork for the last command it was asked to execute.
Because after the last command, it won't be needed anymore.

The difference  between an interactive shell  which ALWAYS fork, and  a subshell
which SOMETIMES doesn't fork, is:

   - the interactive shell doesn't know when it won't be needed anymore

   - the subshell knows exactly the entire set of commands it will have to
     execute during its lifetime

MRE:

    $ find /  | wc -l
    $ pstree --long --show-parents --show-pids $(pidof -s find)
    ... bash───find
        │      │
        │      └ Initially this was a subshell started because `find` was part of a pipeline.
        │
        │        It should have forked a sub-sub-shell to execute `find(1)`.
        │        But it didn't.
        │        Instead it immediately called `execve()`.
        │
        └ current shell from which the pipeline is executed

This is an optimization performed by some shells, for some commands:

- <https://unix.stackexchange.com/a/41424/289772>
- <https://unix.stackexchange.com/a/466523/289772>

---

This is also the reason why you  don't see the subshell executing a script, with
`pstree(1)`.  Since  the subshell has  only one  command to execute,  it doesn't
fork, it just calls `execve()` to replace its image with the one of the script.

---

OTOH, if the command is not the last one, the subshell *will* fork a sub-sub-shell:

    $ ( find / ; true ) | wc -l
    $ pstree --long --show-parents --show-pids $(pidof -s find)
    ... bash───bash───find
        │      │
        │      └ subshell
        │
        └ current shell from which the pipeline is executed

Similarly:

    $ while true; do find / ; done | wc -l
    $ pstree --long --show-parents --show-pids $(pidof -s find)
    ... bash───bash───find

In the last example, the subshell is asked to execute a single `while` loop.
But  a  loop may  execute  several  commands,  so  the subshell  considers  that
`find(1)` is not the last command, and forks.

##
# What are the six basic constructs to build a command-line?

   - simple command
   - pipeline
   - list
   - compound command
   - coprocess
   - shell function definition

# How to execute a command without any shell construct interfering (alias, builtin, function)?

Prefix the command with `env`:

    env [environment variables] <your command>

`env` is  an external  program; it  has no knowledge  of all  the shell-specific
constructs.

<https://unix.stackexchange.com/a/103474/289772>

##
# Quoting
## When does the shell remove a backslash?

Outside quotes, always, unless it's quoted by another backslash.
This is similar to what VimL and tmux do with non-literal strings.

    $ printf '%s' a \z b
    azb

    $ printf '%s' a \\z b
    a\zb

Inside single quotes, never:

    $ printf '%s' 'a \z b'
    a \z b

    $ printf '%s' 'a \\z b'
    a \\z b

Inside double quotes, whenever it's used to remove the special meaning of the next character.

    $ printf '%s' "a \$$ b"
    a $$ b

    $ printf '%s' "a \z b"
    a \z b

##
# Editing output
## How to keep only the first 20 characters in the output of a command?  In each line of a file?

    $ cmd | cut --characters=1-20

    $ cut --characters=1-20 file

##
## My command output is already a table, but the columns are not correctly aligned.  How to align them?

    $ cmd | column -t
                   ^^

## The columns are filled before the rows.  How to fill the rows first?

    $ cmd | column -t -x
                      ^^

## These commands assume that my columns are separated by whitespace.  But they are separated by colons!

    $ cmd | column -t -s:
                      ^^^

##
## My command output is a whitespace separated list of 12 words.  How to format it into a 3 rows x 4 columns table?

    $ cmd | pr --omit-header --length=3 --columns=4

Example:

    $ printf '%s\n' word_{1..12} | pr --omit-header --length=3 --columns=4

## The columns are filled before the rows.  How to fill the rows first?

Add `--across`.

## What happens if I use one of these commands, but my command output contains 24 words?

`pr(1)` will format the  first 12 words in a page, then format  the 12 next ones
in a second page.  The two pages will appear next to each other, which will give
the false impression that there's a single page.

##
# Scripts
## declare

    declare

            Affiche les attributs et valeurs de toutes les variables existantes dans l'environnement
            courant.

            Synopsis simplifié de la commande:

                    declare [-aAfgirx] [-p] [name[=value] ...]


    declare -p    var1 var2
    declare -p -f myfunc
             ^
             print

            Affiche les attributs et valeurs de `var1` et `var2`.
            "                                de `myfunc`

            Il est nécessaire de passer le flag `-f` à `declare` qd on veut afficher la valeur
            d'une fonction, autrement le shell ne la trouvera pas.

## read

`read` accepte plusieurs arguments, entre autres:

    ┌────────────┬──────────────────────────────────────────────────────────────────┐
    │ -e         │ permet d'utiliser les raccourcis readline pendant la saisie      │
    ├────────────┼──────────────────────────────────────────────────────────────────┤
    │ -i "hello" │ ajoute automatiquement "hello" au sein de l'input                │
    │            │                                                                  │
    │            │ ne fonctionne que si readline est utilisée (flag `-e`)           │
    ├────────────┼──────────────────────────────────────────────────────────────────┤
    │ -n 12      │ limiter l'input à 12 caractères                                  │
    ├────────────┼──────────────────────────────────────────────────────────────────┤
    │ -p         │ print given prompt on STDERR if STDIN is connected to terminal   │
    ├────────────┼──────────────────────────────────────────────────────────────────┤
    │ -s         │ mode silencieux ; l'input n'est pas echo sur la sortie standard  │
    ├────────────┼──────────────────────────────────────────────────────────────────┤
    │ -t 34      │ impose un timeout de 34 secondes                                 │
    └────────────┴──────────────────────────────────────────────────────────────────┘

##
# Reference

[1]: https://mywiki.wooledge.org/BashFAQ/048
