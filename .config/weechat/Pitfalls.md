# Always escape semicolons in a command `/exec`uted by an `/alias` or a `/key` binding.

Because both `/alias` and `/key` remove them when parsing their arguments.

From `/help alias`:

   > command: command name with arguments (**many commands can be separated by semicolons**)

From `/help key`:

   > command: command (**many commands can be separated by semicolons**); [...]

But semicolons in an `/exec` are meant to separate *shell* commands, not WeeChat
commands.

---

As an example, don't write this:

    /alias add test /exec -sh echo a; echo b
                                    ^
                                    ✘

But this:

    /alias add test /exec -sh echo a\; echo b
                                    ^^
                                    ✔

# Always respect the original case of a channel when setting an option containing its name!

For example:

    /set logger.level.irc.rizon.#elitewarez 0
                                 ^--------^
                                     ✘

This is supposed  to disable logging for the `#elitewarez`  channel on the Rizon
network.  But it doesn't work, because:

   - the given case doesn't match the original one (here, all uppercase)

   - for  WeeChat, the  case of  an option  name matters; including the part for
     the channel name (even though it  doesn't matter for the IRC protocol: it
     doesn't distinguish `#abc` from `#ABC`)

     See: <https://specs.weechat.org/specs/2023-001-case-sensitive-identifiers.html#changes>

---

Don't trust the name as printed in the buflist.  For example, you can force your
own case with an `autojoin` option:

    /set irc.server.rizon.autojoin "#elite-chat,#elitewarez,#subsplease"
                                                 ^--------^
                                                     ✘

Here, when you'll connect to the Rizon server, you'll automatically join the
`#elitewarez` channel, whose  name will be written in lowercase  in the buflist.
But if  you quit the channel,  then manually re-join  it, it will be  written in
uppercase (as it was originally written  by its creator).

---

If you need to know the original case of a channel's name:

    # can be run in any buffer
    /buffer list

    # must be run in the buffer whose name you need
    /buffer listvar

# Always pass `-sh` to `/exec` when your command contains shell-specific syntaxes (including semicolons).

This includes environment variables:

               v
    /exec echo $SHELL
    $SHELL

          vvv
    /exec -sh echo $SHELL
    /usr/bin/bash

Semicolons:

                 v
    /exec echo a ; echo b
    a ; echo b

          vvv
    /exec -sh echo a ; echo b
    a
    b

Brace expansions:

                v   v
    /exec echo a{b,c}
    a{b,c}

          vvv
    /exec -sh echo a{b,c}
    ab ac

#
# Never put a space after `?` or `:` in a ternary operator.

In those positions, it's semantic; not cosmetic:

    /eval -n ${if:1?/mute}
    [/mute]

                     v     v
    /eval -n ${if:1 ? /mute }
    [ /mute ]
     ^     ^

And `/mute` has not the same effect as ` /mute `.  The latter is not executed as
a (no-op) command, but written into the current buffer.

# Never quote a string from a WeeChat command when it's passed to a Python script.

    /key bind <LHS> /script "argument"
                            ^        ^
                            ✘        ✘

They would be included in the argument passed to the callback function:

                                 vvv
    def command_cb(data, buffer, arg):

So, inside the function, whenever you test  the argument, you would need to take
those into account:

    ✘
    if arg == '...'

    ✔
    if arg == '"..."'

Which might be unexpected.

#
# A server might override the meaning of a command.  Use `/command` to avoid that.

For example,  `/version` prints WeeChat version  when run from the  core buffer;
but when  run from a  channel on Abjects,  it gives an  error.  If you  want the
original meaning, execute:

    /command core version
             ^--^
             /version is built-in; not provided by a plugin

Note that there is a default alias  for that particular command: `/v`.  The only
difference  is that  it passes  the `-o`  flag to  `/version`, which  writes the
output in the current buffer instead of the core buffer.
##
# I can't connect to the server.
## It says I'm K:lined!

Your address  matches an entry  on the server's  internal list of  addresses not
permitted to use it.   Remove the server from your list and try  to connect to a
different one.

---

K:lines are known as  such because the part of the  configuration file where the
server  stores these  “kill  lines”, and  checks upon  them  with each  user
connection, consists of lines beginning with `K:`.

Not all server operators are kind enough to provide a reason, so it might return
no more than a generic "Banned" or "You are not welcome" notice.

The most  common reason for  being K:lined is  that the server's  operators have
observed misbehavior from  users within a group of addresses  (of which yours is
one), and therefore have  decided not to permit any user from  that group to use
the server.  Another reason for a K:line could be that you are expected to use a
server  closer to  you  in  terms of  either  network  topology or  geographical
location.

## It says I'm G:lined!

Some  IRC  networks   that  have  a  global  abuse   policy  implement  G:lines:
network-wide  K:lines (also  called “global  K:lines”).  On  these networks,
repeated  or extensive  abuse might  result  in simultaneous  K:lining from  all
servers on that network.

Many servers admin don't take too much care to remove old K:lines, so they might
remain  in place  indefinitely, even  for  years.  G:lines  tend to  have a  set
expiration date, which can  be anywhere from 20 minutes to a  month after it was
set.  Some modern  server versions use temporary  K:lines, automatically removed
after a short while.

Try to ask one of the server's  operators or email the server's admin address to
have it lifted – if they are inclined to do so.

#
# The connection closes after a minute or two with the message “Ping timeout”!

The server got no reply from your client from the first PING.  It must receive a
PONG reply to confirm that your client is connected and responding.

The cause might be:

   - a slow network connection

   - a heavy load on the server machine
     (which delays the PING on its way to you)

    - a heavy load on your machine
     (which prevents the reply from reaching the server before the timeout)

---

Use  `traceroute(1)` to  diagnose the  connection between  your machine  and the
server:

    $ traceroute irc.libera.chat

# The connection fails with the message
## “timeout”!

Try to connect using only telnet.

    $ telnet irc.libera.chat 6667

You should see something like:

    :iridium.libera.chat NOTICE * :*** Checking Ident
    :iridium.libera.chat NOTICE * :*** Looking up your hostname...
    :iridium.libera.chat NOTICE * :*** Couldn't look up your hostname

If that's not the case, WeeChat is not the issue.
The IRC server is unavailable.

For more info, see:
<https://stackoverflow.com/a/12661281/9780968>

## “No more connections” or “Server full”!

You can either use  another server or wait a little  for the previous connection
to timeout on the server's side.

---

This issue arises when the number of connections the server has allotted to your
connection class is full.

Servers often define address  groups with a maximum limit of  users who might be
connected simultaneously.   For example, they could  assign the class 20  to all
foreign addresses,  and set  a limit  of 50  connections for  this class  in the
configuration file.

In this case,  once the quota of  50 users is exhausted, the  server rejects all
foreign users  attempting to connect,  until at least  one client of  that class
disconnects and frees the spot for another.

---

Another common reason  for these messages is that you  were previously connected
to the server and lost your connection.  But the server hasn't noticed it yet.

As a  result, it detects  your attempt to  reconnect as a  duplicate connection,
which  is forbidden  if the  server permits  a maximum  of one  client from  any
particular address.

## “Connection Refused”!

No IRC server was listening for connections on the machine and/or port you tried
to connect to.  Make sure the server name and the port number are correct.

If the issue persists, the IRC server or the machine is having a problem.
Try to connect to a different server.

## “Unable to Resolve Server Name”!

A   name  server   has  failed   to  convert   the  canonical   name,  such   as
`irc.server.com`, into an IP address such as `256.10.2.78`.

Either your local name  server or the one on which  the server's address resides
are out of order.

Your client sends your  query to your local name server, which  in turn looks up
the name server  that holds the records of the  server's site (`server.com`) and
then queries it for the IP address matching the canonical name you have given it
(`irc.server.com`).

If this happens with  all servers, it's definitely your local  server that has a
problem.

If your ISP can't fix the issue for a while, either use an off-site name server,
which requires  you to know a  name server's IP  address, or find an  IP address
from an existing list of them.  The  easier solution is to find the IP addresses
of the IRC  servers you use most and  add them to your list  separately.  If you
don't know any,  try asking on one  of the other networks' help  channel, or try
the network's website if there is one.

## “No Authorization”!

You might  be trying to  connect to  a foreign server,  which accepts few  or no
users from outside its domain.

---

Another explanation is name server failure.  The server might attempt to convert
your IP address into a canonical host name.

But  some ISPs  have omitted  adding reverse  records for  their addresses,  not
considering it  essential to smooth operation.   And the server might  refuse to
accept users whose IP address will not resolve to a canonical host name.

To check whether your ISP has set up reverse DNS for your IP, execute this shell
command:

    $ dig +noall +answer -x <your IP>

It should contain  a hostname.  If not, ask  your ISP to set up  reverse DNS for
your IP.

#
# The server sends me the message
## “Illegal Nickname”!

You've selected a nickname that's already in use, or it contains an unacceptable
character.   Valid  characters  for  nicknames include  the  characters  in  the
following set:

    [a-zA-Z0-9\`^-|_[]{}]

The leading character cannot be a number or dash.

---

Note that two nicknames which seem to be different might still conflict.
Indeed, IRC is not case-sensitive: so `user` is the same as `UsEr`.

Besides, the following pairs of characters are confused by many servers:

    [ ↔ {
    ] ↔ }
    | ↔ \

Indeed, IRC  originated in  Scandinavia, and on  a Scandinavian  keyboard, those
keys correspond to the same keys (with/out the shift modifier).

---

If the nickname is valid and someone else is using your first choice, as well as
your  alternative nicknames,  the server  prompts you  to enter  a new  nickname
before it will accept  you.  If you don't enter a new  nickname soon enough, the
server disconnects you with a Ping timeout.

---

Some servers  or networks  might reject  nicknames that  would be  legitimate on
other  servers, such  as those  with an  underscore in  them.  If  you can  find
nothing  else wrong  with  your nickname,  try  using one  made  up entirely  of
letters.

## “Nickname or Channel Temporarily Unavailable”!

You need to select a new nickname before the server accepts you.

---

The nickname was  recently in use by  someone who didn't sign  off "normally" as
seen from  your server.  Maybe the  user was disconnected by  accident, and will
reconnect soon.  Even if the user  signed off normally, some servers prevent the
use of the nickname for approximately 15 minutes.

---

You might change back to your original nickname after the nick delay expires and
the nickname becomes available again.

#
# I end up on a different server than the one I asked!

The server  you asked to  connect to might have  been taken down  permanently or
temporarily.  To spare the users the  trouble of looking for another server, its
administration might have chosen to redirect them to a different server.
