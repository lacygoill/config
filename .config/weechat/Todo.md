# report typo in output of `/help eval`

   > - split of shell **argmuents** (format: "split_shell:number,xxx")

It should be "arguments".

# find out why we can see away nicks in the nicklist even though `irc.server*.away_check` is set to 0

And even on big channels with more than the default 25 nicks (`irc.server*.away_check_max_nicks`).

# add Twitch to list of known networks

Try this:

    /mute /server add twitch irc.twitch.tv/6667

    # only necessary in our config file where we execute: /unset -mask irc.server.*
    /set irc.server.twitch.addresses "irc.twitch.tv/6667"

    # to get the authentication token, go here: http://www.twitchapps.com/tmi
    /set irc.server.twitch.password "oauth:<token>"

    /set irc.server.twitch.nicks "<twitchUserName>"
    /set irc.server.twitch.username "<twitchUserName>"

I'm  not  sure you  should  append  `/6667` to  the  host  name.  If  you  reset
`irc.server.twitch.tls` to `off`,  WeeChat should already connect  to port 6667.
But is it OK to reset TLS?  I would be surprised if Twitch didn't support TLS...

See also: <https://weechat.org/scripts/source/twitch.py.html/>

# improve completion mechanism

When we complete a command, each suggestion  is appended with a space.  It seems
confusing because we  might think that the suggestion was  accepted.  Ideally, a
suggestion would not be appended with anything; this would serve 2 purposes:

   - it would let us know that a completion is still active
   - we could end the completion by inserting a space (ATM, we need to press
     2 keys: SPC + BS or BS + SPC)

BTW, I don't think there is any `/input` action to accept the current completion
without executing the  input command, is there?   Also, there is no  way to test
whether a completion is currently active, is there?

##
# learn how to
## use a cloak to hide our IP

WeeChat is responsible for your nick, user name, and real name.
But not for your host name.

A cloak is a host name substitute offered by some servers.
On Libera, run:

    /msg NickServ help

And see whether the NickServ bot supports some cloak-related command(s).
You might need to join `#libera-cloak`...

## support other chat protocols via BitlBee

It lets you chat via Twitter, Google Talk, MSN, ... from your IRC client.

## access WeeChat from any device with a browser

   - <https://hveem.no/a-modern-IRC-experience>
   - <https://github.com/glowing-bear/glowing-bear/>

As a benefit, multimedia contents (like images and videos) is embedded.

---

What's a "remote GUI/interface"?
<https://weechat.org/about/interfaces/>

Would it let us access WeeChat from any device?

## set up an IRC channel

<https://botbot.me/how-to-setup-irc-channel/>

Once you've set up a channel, you need to moderate it; document these commands:

   - `/ban <nick>`
   - `/kick <nick>`
   - `/kickban <nick>`

## set up an IRC bouncer (like ZNC)

To maintain a persistent connection to all of our IRC channels.

##
# assimilate third-party scripts
## `auto_away`, `away_action`

 - <https://weechat.org/scripts/source/auto_away.py.html/>
 - <https://weechat.org/scripts/source/away_action.py.html/>

## `histsearch`

<https://weechat.org/scripts/source/histsearch.py.html/>

## `pybuffer`

<https://weechat.org/scripts/source/pybuffer.py.html/>

## `xfer_run_command`

<https://weechat.org/scripts/source/xfer_run_command.py.html/>

To send a desktop  notification when a download ends; and  maybe when it's ready
to start too.
