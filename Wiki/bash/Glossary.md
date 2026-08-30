# a
## alias/function

An alias is a word which is expanded by the shell into an arbitrary command-line.
A function allows a set of commands to be executed with a simple word.

## argument

From the shell's point of view, everything is an argument.
For example:

    $ ls -I README -l foo 'bar car' baz

The shell parses this command-line into 7 arguments passed to `execve(2)`:

   1. ls           command name
   2. -I           option
   3. README       parameter to the `-I` option
   4. -l           option
   5. foo          positional parameter
   6. 'bar car'    positional parameter
   7. baz          positional parameter

For more info: <https://stackoverflow.com/a/40654885/9780968>

## associative array

It's an Abstract Data Type, composed of a collection of (key, value) pairs, such
that each possible key appears at most once in the collection.

A  hash table  is  a concrete  (!=  abstract) data  structure,  i.e. a  possible
implementation of an associative array.

For more info: <https://cs.stackexchange.com/a/6687>
*Relation and difference between associative array and hashing table?*

##
# d
## dynamic scoping

The  variables of  a given  function and  their values  are shared  between that
function and  its caller  (whether that  caller is the  global scope  or another
shell function).  This means that the scope of a given function variable depends
on  the  sequence of  calls  that  caused  execution  to reach  that  particular
function.   IOW, it  depends on  the  call stack,  at runtime.   This is  called
**dynamic scoping**.

The `local`  builtin can be used  to limit the  visibility of a variable  to the
current function (and the functions that it calls or defines), which prevents it
from being visible  by a caller.  However, it doesn't  prevent the variable from
being visible by callees; thus, its  scope remains dynamic (unless, I guess, you
declare  it as  `local` in  every single  function, regardless  of whether  that
function actually uses the variable).

##
# e
## execution environment

The shell has an execution environment, which consists of the following:

   - open files inherited  at invocation (possibly modified  by redirections
     supplied to `exec`)

   - the current working directory

   - the file creation mode mask   inherited  from the shell's parent (or set by
     `umask`)

   - traps set by `trap`

   - parameters that are set by variable assignment, or with `set`, or inherited
     from the shell's parent in the environment

   - functions defined during execution or inherited  from  the shell's parent
     in the environment (a function can be exported via `export -f`)

   - options  enabled  at  invocation (either by default or with command-line
     arguments) or by `set`

   - options enabled by `shopt`

   - aliases defined with `alias`

   - various process IDs, including those  of  background  jobs,  the value of
     `$$`, and the value of `PPID`

---

When a simple command other than a  builtin or shell function is to be executed,
it  is invoked  in  a  *separate* execution  environment  that  consists of  the
following (unless otherwise noted, the values are inherited from the shell):

   - the shell's open files, plus  any  modifications  and  additions specified
     by redirections to the command (exception: in a script, the STDIN of
     a command followed by `&` is `/dev/null`)

   - the current working directory

   - the file creation mode mask

   - shell  variables  and  functions  marked  for export, along with variables
     exported for the command, passed in the environment

   - traps caught by the shell are reset to the values inherited from the
     shell's parent, and traps ignored by the shell are ignored

A  command  invoked in  this  separate  environment  cannot affect  the  shell's
execution environment.

##
# f
## fork

When  you execute  a  shell command,  the shell  duplicates  itself by  invoking
`fork(2)`.  The duplicate shell is called a “fork” of the original shell.

Then, the  fork replaces  its code  with the one  of the  command by  invoking a
family of system calls informally called “exec()”.

You can do manually replace the code of the current shell using the `exec` command:

    $ echo $SHELL
    zsh

    $ exec bash

    $ echo $SHELL
    bash

Here,  `$ exec bash` has  not  started a  subshell.  You're  still  in the  same
process, which is confirmed by the fact  that when you press `C-d`, the terminal
window closes (instead of getting back to the prompt of the parent shell).

For more info: `man 3 exec`.

##
# h
## hash table

Whenever  you  ask bash  to  execute  a  command, it  has  to  look in  all  the
directories of `$PATH`.   After having found the full path  to the command, it's
saved inside a compiled table whose elements look like this:

    command=/path/to/command

The next  time you'll  ask to execute  the same command,  bash won't  re-look in
`$PATH` but in the table, which is faster.

---

To print its contents, run:

    $ hash

And to empty it:

    $ hash -r

This is useful  when bash finds a wrong  location, and you don't want  to open a
new terminal.

##
# i
## IFS

The Internal  Field Separator is  used for word  splitting, and to  split `read`
lines into words.  The default value is `<space><tab><newline>`.

Example:
```bash
IFS=:
var='a b:c'
printf '%s\n' $var
 #            ^--^
```
    a b
    c

bash  has splitted  on  the colon  from  `IFS`, because  there  was an  unquoted
parameter expansion (`$var`) whose value contained a colon.

Counter-example:
```bash
IFS=:
printf '%s\n' a b:c
 #            ^---^
```
    a
    b:c

This time, even though `IFS` was re-set to  `:`, bash did not split on the colon
instead  of  the  space.   That's  because  there  was  no  parameter/arithmetic
expansion, nor command substitution, and thus no word splitting.

## IFS whitespace characters

Any `<space>`, `<tab>`, or `<newline>` inside the value of `IFS`.

##
# j
## job

A background process.

A background process doesn't read its input from the terminal anymore.
Also, it doesn't receive keyboard-generated signals.

This gives back to the user the control of the shell.

##
# n
## nameref

In bash, a  nameref is a variable  whose value is the name  of another variable.
Any reference  or assignment to  a nameref is  actually performed on  that other
variable.

To create a nameref, `declare -n` can be used:
```bash
declare -n a
a='b'
b='c'
echo "$a"
```
    c
```bash
declare a
a='b'
b='c'
echo "$a"
```
    b

To unset a nameref:

    unset -n ref
          ^^

Note that without  `-n`, `unset` would unset whatever variable  is referenced by
`ref`; not `ref` itself.

##
# o
## option

An option is  an optional argument to  a command, which is  documented (i.e. you
can't write any arbitrary option name), and whose possible values are hard coded
in the program.

A boolean option is sometimes called “flag” or “switch”.

##
# p
## parameter

A parameter  is an argument that  provides information to either  the command or
one of its options.

E.g., in `-o file`, `file` is the parameter of the `-o` option.

Unlike options, whose possible values are hard coded in programs, parameters are
usually not, so the user is free to use whatever string suits their needs.

If you  need to  pass a  parameter that looks  like an  option but  shouldn't be
interpreted as such, you can separate it from the options with a double hyphen.

See:
   - <https://stackoverflow.com/a/36495940/9780968>
   - <https://stackoverflow.com/a/40654885/9780968>

## special parameter

A parameter whose meaning is entirely defined by the shell:

    $*
    $@
    $#
    $?
    $-
    $$
    $!
    $0
    $_

## positional parameter

Any remaining arguments after the options have been consumed are commonly called
positional parameters  when the  order in  which they  are given  is significant
(this is in contrast to options which usually can be given in any order).

In a script, you can access them through the variables `$1`, `$2`, ...
And you can access the script name with `$0`.

## process

A program is executed in a process running in the computer's memory.

A process stores some information about the program it's executing:

   - PID
   - state (running, stopped, ...)
   - cwd
   - environment variables

## program

Code stored in a file on the hard drive.

##
# s
## shell

Interface between the user (or a script) and the kernel.

## subshell

Some commands are  invoked in a **subshell** environment that  is a duplicate of
the shell execution environment (except that traps caught by the shell are reset
to the values that the shell inherited from its parent at invocation):

   - command substitution
   - commands grouped with parentheses
   - commands (even builtins (*)) invoked as part of a pipeline
   - asynchronous commands

Changes made  to the  subshell environment cannot  affect the  shell's execution
environment.

(*) Watch this:

              vvv
    $ test $$ -eq "$BASHPID" && echo '"test" builtin does *not* run in a subshell'
    "test" builtin does *not* run in a subshell

        v         vvv
    $ : | test $$ -ne "$BASHPID" && echo '"test" builtin *does* run in a subshell'
    "test" builtin *does* run in a subshell

## syntactic whitespace

Unquoted/unescaped space or tab.

This is a whitespace which has a special meaning to the shell.

##
# v
## variable

A parameter whose first character matches`[a-zA-Z0-9_]`.

## environment variable

Parameter stored in the current shell's environment.

It will be automatically passed to any child process of the shell.
It allows inter-process communication.

##
# w
## word splitting

After performing a parameter/arithmetic  expansion or command substitution, bash
splits  the  result  into  words  (unless the  syntax  was  quoted),  using  the
characters listed inside `IFS` as delimiters.

There are 3 cases to consider:

   - `IFS` is null: no word splitting occurs.

   - `IFS` is unset or `<space><tab><newline>` (default value): a sequence of
     `IFS` whitespace characters delimits words, unless at the beginning or end
     of the expansion (where it's ignored).

   - `IFS` has a value other than the default: same thing as if `IFS` kept its
     default value, with one addition: any character which is not a whitespace
     `IFS` character, along with  any adjacent  `IFS` whitespace characters (*),
     delimits a field.

(*) Consider this:

          vv          vv
    $ IFS=+-; var='a b+-c'; printf '|%s|\n' $var
    |a b|
    ||
    |c|

Notice that the sequence `+-` was not treated as a single delimiter, but two.
That's why you get a null argument in the middle.
Now, watch this:

            vvv            vvv
    $ IFS=$'+\t'; var=$'a b+\tc'; printf '|%s|\n' $var
    |a b|
    |c|

This time, there  is no null argument, because the  sequence `+\t` *was* treated
as a single delimiter.
