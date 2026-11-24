# Style
## When setting an option value, put quotes around a string; but not around a color name.

                                  v       v
    /set irc.server.oftc.autojoin "#debian"
    /set weechat.bar.status.color_fg white

Quotes are not needed, even for strings, but using them makes the code easier to
read.

##
# Misc
## Which shell is invoked by `/exec -sh`?

Whatever is assigned to `exec.command.shell`.

## What's the meaning of `~` in front of a nick?

It means that the server was not able  to look up the “real username” of the
client.

   > Some  servers  set the  username  of  connecting clients  automatically  by
   > relying on the Ident Protocol. In these servers, the username retrieved via
   > Ident is preferred over the one submitted by the client. When connecting to
   > these servers,  if the submitted  <username> is  used, it will  commonly be
   > prefixed with a tilde (~) to indicate that it's user-set.

Source: <https://dd.ircdocs.horse/refs/commands/user>

   > Servers MAY  use the Ident Protocol  to look up the  ‘real username’ of
   > clients. If username  lookups are  enabled and  a client  does not  have an
   > Identity  Server enabled,  the username  provided by  the client  SHOULD be
   > prefixed by a tilde ('~', 0x7E) to show that this value is user-set.

Source: <https://modern.ircdocs.horse/#user-message>

From  WeeChat's perspective,  it's part  of the  username, which  it expects  to
receive from the server.

## What is the difference between `${color:default}` and `${color:reset}`?

It seems  that both  `default` and  `reset` can  restore the  default foreground
color  and clear  all attributes  (bold, italic,  ...). But  only `default`  can
restore the background color.
