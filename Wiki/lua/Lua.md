# Lua interpreter
## How to configure it?

Set the `LUA_INIT` shell environment variable.
If the value starts with `@`, the interpreter will interpret what follows as the
path to a script to run.  Otherwise, it's interpreted as Lua code to run.

For example, in fish,  you can change the prompt of the  interpreter to `:` like
this:

                             lua global variable with special meaning
                             v-----v
    $ set --export LUA_INIT '_PROMPT = ": "'

###
## How to start it in interactive mode in the shell?

    $ lua -i
          ^^

### How to exit it?

    > os.exit()

Or press `C-d`.

###
## How to print the evaluation of an expression without `print()`?

Use `=`:

    $ lua
    > = 1 + 2
    3

## How to print the path used by `require()` to search for a Lua/C loader?

    > print(package.path)
    > print(package.cpath)

See:
   - <https://www.lua.org/manual/5.1/manual.html#pdf-package.path>
   - <https://www.lua.org/manual/5.1/manual.html#pdf-package.cpath>

##
## How to retrieve the arguments passed on the shell command-line?

Use the `arg` table.
If a script was passed, its index is 0 in the table.
If the script itself was followed by arguments, their indexes are 1, 2, ...

    $ cd /tmp
    $ touch lua.lua

    $ lua -i -e 'sin = math.sin' lua.lua a b
    > = arg[0]
    lua.lua
    > = arg[1]
    a
    > = arg[2]
    b

Anything before has a negative index.

    > = arg[-1]
    sin = math.sin
    > = arg[-2]
    -e
    > = arg[-3]
    -i
    > = arg[-4]
    lua

##
# Syntax
## Which values are truthy?

All of them, except `false` (obviously) and `nil`.
In particular, this means that 0 and  the empty string are truthy (which differs
from other programming languages).
