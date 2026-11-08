# mailcap
## What does “mailcap” stand for?

“metamail capabilities”.

## What does “metamail” stand for?

Originally,  it  was the  name  of  a utility  for  integrating  MIME into  mail
programs.  When  such a program  – like  `mutt(1)` – encountered  a non-text
message that it could  not handle itself, it would call  metamail to decode and,
if possible, display it.

Nowadays, on  an Ubuntu system,  there is no  `metamail` program; I  *think* the
equivalent  is  the `run-mailcap(1)`  utility,  provided  by the  `mime-support`
package.

Note that whatever the "metamail" utility is on your system, it's not limited to
mail programs; for example, rtv (a TUI reddit client) can leverage the
"metamail" utility to display images or read videos.

##
## What is the purpose of
### the `mime.types` files?

They map files' extensions to mimetypes.

### the `mailcap` files?

They map mimetypes to arbitrary commands designed to process files.

#### Where are they?

You can find them with:

    $ locate -r '/mime.types$'
    $ locate -r '/mailcap$'

There are mainly 4 such files:

   - `~/.mime.types` (user)
   - `~/.mailcap` (user)

   - `/etc/mime.types` (system-wide)
   - `/etc/mailcap` (system-wide)

The user files have priority over the system ones.

###
## In a mailcap file, what is the overall syntax of a rule?

It's a semicolon-separated sequence of fields.

The first field specifies a mimetype.
The second field specifies a command to execute.
The remaining fields (if any) can be used to specify commands for other actions,
and/or optional flags.

Here is an example:

    text/plain; cat '%s'; edit=vim '%s'; needsterminal
    ├─────────┘ ├──────┘  ├───────────┘  ├───────────┘
    │           │         │              └ optional flag
    │           │         └ command for other action
    │           └ command to execute
    └ mimetype

A mimetype specifies a content type (e.g. `text`) and a subtype which is usually
an encoding (e.g. `plain`), the two separated by a slash:

    type/subtype

Note that a  wildcard can be used to  match any type or any subtype;  so each of
these strings is a valid first field:

   - `type/*`
   - `*/subtype`
   - `*/*`

### How is the mimetype field used?

It's matched  against the  mimetype of  the file  which `run-mailcap(1)`  has to
process, to decide whether the rule applies or not.

###
### About the command field
#### how is it used?

It's passed to the `sh(1)` shell via `system(3)` which executes it.

#### what is `%s` replaced with?

With the name of the file that needs to be processed.

#### how to include a semicolon inside?

Quote it with a backslash:

    text/plain; cat '%s' \; echo 'still part of the command field'
                         ^

###
### How to make a mailcap rule apply only on some arbitrary condition?

Include an optional `test=CMD` field inside the rule.

`CMD` can  be any  command, and  include a  `%s` escape  sequence which  will be
replaced with the name  of the file to process.  It is  considered to succeed if
and only if it exits with a zero exit status.

Example:

    image/*; feh '%s'; test=test -n "$DISPLAY"
                            ^----------------^

Here, `CMD`  is the shell builtin  `test`, which checks whether  the environment
variable is set, which should be the case only when a display server (like Xorg)
is running.  IOW,  this mailcap rule can only apply  in a graphical environment;
not in console.

### Which flag should I always include for a command which needs to interact with the user on a terminal?

    needsterminal

It will typically cause the creation of a terminal window, unless you're already
in a terminal.

### What is the purpose of the optional `description=` field?

It specifies a textual description for the file, which could be displayed by the
calling  program (`mutt(1)`,  rtv, ...)  before  handling the  processing to  an
external command.

It's  probably similar  to  the  `alt` attribute  in  HTML,  which specifies  an
alternate text for an image (in case  it cannot be displayed by the web browser,
or in case the user hovers the mouse over it to get some quick description).

###
### If 2 rules conflict with each other, which one wins?

The first one which is read.  That's why the order in which you write your rules
matters.

#### How can I give more importance to a rule without changing its location?

Include the optional field `priority=N`, where `N` is a number between 0 and 9.

The higher  `N` is, the more  likely your rule is  to win in case  of a conflict
with another rule which handles the same mimetype.

---

If you omit this field, `priority=5` is assumed.

##### For a rule whose mimetype contains a wildcard, which priority should I use?

If the wildcard is only used for the subtype, use a priority lower than 5.
Rationale: This way, more specific rules which could be read later will win.

If the wildcard is used for for the type *and* the subtype, use the priority 0.
Rationale: This way, the  rule is only used  as a last resort (i.e.  if no other
rule has matched in the end).

##
## Suppose a program wants to advertise that it can process a mimetype:

For example, transmission-gtk can process torrent files whose mimetype is:

    application/x-bittorrent

### Where should it create a file to add its mailcap rule(s)?

Inside this directory:

    /usr/lib/mime/packages/

As an example:

    $ tee /usr/lib/mime/packages/transmission-gtk <<'EOF'
        application/x-bittorrent \
            ; transmission-gtk %s \
            ; description="GTK-based BitTorrent client" \
            ; test=test -n "$DISPLAY"
    EOF

### How does the system pick up this file?

When  a  package is  installed  or  removed,  the system  automatically  invokes
`update-mime(8)` which  parses all the files  under `/usr/lib/mime/packages`, to
find mailcap rules which are then used to create or update `/etc/mailcap`.

---

`update-mime(8)`  also parses  desktop  files  in `/usr/share/applications/`  to
generate mailcap  rules.  These rules are  given a lower priority  than those in
`/usr/lib/mime/packages`.

###
# `run-mailcap(1)`
## What is the purpose of this command?

It processes a file via a program specified in the rules of the mailcap files.

    $ run-mailcap FILE ...

---

Note that actually, `FILE` can be more  specific, and include a mimetype as well
as an encoding (both of which are optional), separated with colons:

    MIME-TYPE:ENCODING:FILE

If the mimetype is omitted, it's  inferred from the `mime.types` files using the
file's  extension.   If that  fails,  a  last attempt  is  done  by running  the
`file(1)` command, if available.

If the encoding is omitted, it will be determined from the file's extension.
The only supported encodings are:

    ┌──────────┬───────────┐
    │ encoding │ extension │
    ├──────────┼───────────┤
    │   gzip   │    .gz    │
    ├──────────┼───────────┤
    │   bzip   │    .bz2   │
    ├──────────┼───────────┤
    │    xz    │    .xz    │
    ├──────────┼───────────┤
    │ compress │    .Z     │
    └──────────┴───────────┘

### The command fails to do what I want!  How to find out why?

Use the optional argument `--debug` to get more info:

    $ run-mailcap --debug FILE ...
                  ^-----^

### Under which other names can it be invoked?  (4)

   - `compose`
   - `edit`
   - `print`
   - `see`

Those names are just aliases.

For example:

    $ ls -l $(which edit)
    lrwxrwxrwx ... /usr/bin/edit -> run-mailcap

This is a bit  similar to Vim, which can be invoked  under different names, like
`view` or `ex`.

#### How does `run-mailcap` react when invoked under one of those?

The name  under which  the `run-mailcap` binary  is invoked is  used to  set the
`--action` option.  For example:

    $ edit
    ⇔
    $ run-mailcap --action=edit
                  ^-----------^

This action determines *how* the file is processed; it can be:

   - created (`compose`)
   - altered (`edit`)
   - printed (`print`)
   - displayed (`see`)

In practice, the action  is matched against an option with the  same name in any
mailcap rule.  For example, suppose that you have this rule in `~/.mailcap`:

    text/plain; less %s; edit=vim %s; compose=nano %s

And some text file:

    $ echo 'text' >/tmp/file

`edit` will open it with Vim:

    $ edit /tmp/file

But `compose` will open it with nano:

    $ compose /tmp/file

That's because the `edit` and `compose`  option are set to different programs in
the mailcap rule.

---

When the action is omitted, `view` is assumed; be it when:

   - you invoke `run-mailcap`
   - you write a rule in a mailcap file

Test:

    $ echo 'text' >/tmp/file
    $ echo 'text/plain; less %s; edit=vim %s; compose=nano %s' >>~/.mailcap
    $ run-mailcap /tmp/file
    the file is opened with less(1)

    $ sed -i '$d' ~/.mailcap

#### How to get the same results by executing the `run-mailcap` command directly?

Specify how you want the file to be processed via the optional argument `--action`:

    edit FILE
    ⇔
    run-mailcap --action=edit FILE
                ^-----------^

---

All the  action names are  identical to the  command aliases, except  the `view`
action which matches the `see(1)` alias:

    see FILE
    ⇔
    run-mailcap --action=view FILE
                ^-----------^


I *guess* that's because `view` is already taken by Vim:

    $ ls -l $(which view)
    lrwxrwxrwx ... /usr/local/bin/view -> vim

##
## How to process the output of a shell command via `run-mailcap`?

Use a pipe and the special filename `-`:

    $ gzip --stdout some.gif >some.gif.gz

                                             v               v
    $ gzip --decompress --stdout some.gif.gz | see image/gif:-
     (+) Video --vid=1 (gif 480x270 30.000fps)
     ...

Note that in this case, a mimetype *must* be specified:

    $ gzip --decompress --stdout some.gif.gz | see image/gif:-
                                                   ^-------^
                                                   mandatory

Without, `run-mailcap` would fail:

    $ gzip --decompress --stdout some.gif.gz | see -
    Failed to recognize file format.

## How to display the final command with which `run-mailcap` will process a given file?

Use the optional argument `--norun`:

    $ run-mailcap --norun FILE
                  ^-----^
