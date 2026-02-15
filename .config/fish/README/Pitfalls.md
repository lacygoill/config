# Why should I always quote a command substitution if it's used in a cartesian product?

Without, you could get unexpected results:
```fish
echo $(printf 'a
b')'c'
```
    ac bc

Here, the output of `printf` contains 2 lines.
Each of these lines is passed as a separate argument to the outer `echo`.
IOW, the previous snippet is equivalent to this:
```fish
set list a b
echo $list'c'
```
    ac bc

From `man fish-language /PARAMETER EXPANSION/;/^\s*Command substitution`:

   > When you write a command in parenthesis  like  outercommand  (innercom‐
   > mand),  the  innercommand  will  be  executed first. Its output will be
   > taken and each line given as a separate argument to outercommand, which
   > will then be executed.

But that's probably not what you expected.
To prevent this, quote the command substitution:
```fish
echo "$(printf 'a
b')"'c'
```
    a
    bc

---

Here is  another way to compare  how fish processes a  command substitution with
and without quotes:
```fish
set list "$(printf 'a
b')"; set --show list
```
    $list: set in global scope, unexported, with 1 elements
    $list[1]: |a\nb|
```fish
set list $(printf 'a
b'); set --show list
```
    $list: set in global scope, unexported, with 2 elements
    $list[1]: |a|
    $list[2]: |b|

# When should I quote a variable expansion passed as argument to `commandline --replace`?

If it contains several  elements, and you don't want those  to be separated with
newlines.

Test:
```fish
bind \cx\cx func
function func
    set -f var $(printf 'a\nb')
    commandline --replace $var
end
```
    a
    b

If you would rather the elements to be separated with spaces, quote the variable
(and prefix it with  `--` in case it evaluates to something  which looks like an
option):

    commandline --replace -- "$var"
                          ^^ ^    ^

Test:
```fish
bind \cx\cx func
function func
    set -f var $(printf 'a\nb')
    commandline --replace -- "$var"
end
```
    a b

# `commandline --replace -- "$var"` appends an unexpected space!

Make sure that `var` does not contain an empty element.

`commandline(1)`  separates 2  consecutive elements  with a  space or  a newline
(depending on whether the variable is quoted), even if the 2nd one is empty.

MRE:

    $ set var $(printf 'x\n\n'); set --show var
    $var: set in global scope, unexported, with 2 elements˜
    $var[1]: |x|˜
    $var[2]: ||˜

    $ commandline --replace -- "$var"

Here, a solution would be to quote the command substitution:

              v                 v
    $ set var "$(printf 'x\n\n')"; set --show var
    $var: set in global scope, unexported, with 1 elements˜
    $var[1]: |x|˜

#
# When do I need to separate options from operands with `--`?

When *any* of the operands has a value starting with a hyphen.
It doesn't even need to be the first one:

                                      v
    $ string replace --regex 'a' 'b' '-a'
    # error

                             vv          v
    $ string replace --regex -- 'a' 'b' '-a'
    -b

Here, notice that the first operand whose  value starts with a hyphen is not the
first one, but the  third one.  And yet, it causes the  command to fail, because
it's parsed as an option.  That doesn't happen if you specify the end of options
with `--`.

---

This implies that if  any of your arguments is an expression  whose value is not
known before  runtime (e.g. `$variable`), then  you should use `--`  to be safe.
Otherwise, if it evaluates to a string starting with `-`, you'll probably get an
error.

## But I don't need `--` here:

    $ set mylist -a

                 no --
                 v
    $ set --query mylist[1]
    # no error

### Why?

I guess  that's because `mylist[1]` is  evaluated by the `set`  builtin, *after*
the command has been parsed.
