# coding=utf-8
# Usage:{{{
#
# Load the script manually:
#
#     /script load toggle_time.py
#
# Or automatically:
#
#     $ cd ~/.config/weechat/python/autoload/
#     $ ln -s ../toggle_time.py
#
# Then, bind a key with your format, for example:
#
#     /key bind meta-t /toggle_time %H:%M:%S
#}}}
# Do you use this script?{{{
#
# No.
# We've a simpler alternative:
#
#     /trigger add cmd_toggle_time command toggle_time
#     /trigger set cmd_toggle_time command /mute /set weechat.look.buffer_time_format "${if:${weechat.look.buffer_time_format}==?${tg_argv1}:}"
#
# Source:
#
#     https://github.com/weechat/weechat/wiki/Triggers#toggle-time-display-on-buffer-like-toggle_timepy
#}}}
# Why do you keep it?{{{
#
# Educational purpose.
#}}}

import weechat

# Where did you find the signature of the callback?{{{
#
#     https://weechat.org/files/doc/stable/weechat_scripting.en.html#hook_command
#}}}
# Why do you call the 2nd argument `buffer_cb` instead of simply `buffer` (like in the doc)?{{{
#
# Because of a warning given by `pylint(1)`:
#
#     W: xx,xx: Redefining built-in 'buffer' (redefined-builtin)
#}}}
def cmd_cb(data, buffer_cb, time_fmt):
    #                       │
    #                       └ ex: '%H:%M:%S'

    # Why?{{{
    #
    # If the timestamps are currently displayed, we want to hide them.
    #
    # To do  this, we need to  check the current value  of 'buffer_time_format',
    # and if  if's not empty we  need to empty  the time format received  by the
    # callback.
    #}}}
    if weechat.config_string(weechat.config_get('weechat.look.buffer_time_format')):
        time_fmt = ''
    # What's the effect of the `/mute` command?{{{
    #
    # It executes the following command silently.
    #}}}
    weechat.command('', '/mute set weechat.look.buffer_time_format "{}"'.format(time_fmt))
    #                                                              ├────────────────┘{{{
    #                                                              └ printf-like syntax for python;
    #                                                                alternative:
    #
    #                                                                    "%s"' % args
    #}}}
    # Why do you return this?{{{
    #
    # From:
    #     https://weechat.org/files/doc/stable/weechat_scripting.en.html#callbacks
    #
    # >   Almost all WeeChat callbacks must return WEECHAT_RC_OK or WEECHAT_RC_ERROR
    # >   (exception is modifier callback, which returns a string).
    #}}}
    return weechat.WEECHAT_RC_OK

weechat.register(
    'toggle_time',    # internal name of the script
    'lacygoill',      # author name of the script
    '1.0',            # script version
    'GPL3',           # license
    'Toggle timestamp in buffers',    # description
    '',    # name of function called when script is unloaded (shutdown_function)
    ''     # script charset
           # (if your script is UTF-8, you can use blank value here,
           # because UTF-8 is default charset)
)

# Where did you find the signature of `hook_command()`?{{{
#
#     https://weechat.org/files/doc/stable/weechat_plugin_api.en.html#_hook_command
#}}}
weechat.hook_command(
    'toggle_time', # command name
    '',            # description for command (displayed with /help toggle_time)
    '',            # arguments for command (displayed with /help toggle_time)
    '',            # description of arguments (displayed with /help toggle_time)
    '',            # completion template for command
    'cmd_cb',      # function called when command is used, arguments and return value
    '',            # pointer given to callback when it is called by WeeChat
)

