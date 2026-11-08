# `shellcheck(1)`
## My test expression cannot be parsed!
```bash
op=-f
[ "$op" file ]
```
    Couldn't parse this test expression. Fix to allow more checks.

Try to replace `[` with `test`:
```bash
op=-f
test "$op" file
```
From `man shellcheck /KNOWN INCOMPATIBILITIES/;/unconventional`:

   > For unconventional or dynamic uses of the [ command, use test or \[ instead.

## No error is given when I declare some variable without using it!

Does its name start with an underscore?
If yes, then shellcheck intentionally ignores this error since this commit:
<https://github.com/koalaman/shellcheck/commit/81b7ee55980962a4631aef5bf98b3cc21822c5a4>

Rationale: ShellCheck follows  a widely-used convention among  other programming
languages, which  states that an  underscore prefix means  that a symbol  is not
used.
##
# `xdg-open(1)` doesn't use the program I want to open my file.  But the right program is written here!

Make sure the syntax of the line is correct.
In particular, there should never be a full path to a desktop file:

    ✘
    application/epub+zip=/usr/share/applications/atril.desktop
                         ^----------------------^
                         needs to be removed

    ✔
    application/epub+zip=atril.desktop
                         ^-----------^

---

Also, if your line is not below this section:

    [Default Applications]

but another one, like this one:

    [Added Associations]

It might be ignored.  If so, try to move it in the “Default Applications” section.
