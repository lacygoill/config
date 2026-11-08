set -f channel $(
  xfconf-query --list \
      | sed '/^Channels:/d; s/^\s*//' \
      | sort \
      | fzf --header=channel \
)
commandline --function repaint

if test -z "$channel"
    return
end

set -f property_value $(
    xfconf-query --channel=$channel --list --verbose \
    | fzf --header=property \
)
commandline --function repaint

if test -z "$property_value"
    return
end

string match --regex --quiet '^(?<property>\S+)\s+(?<value>.*)' -- $property_value
set -f cmdline xfconf-query \
    --channel=$channel \
    --property=\'$property\' \
    --set=\'$value\'  ' # to remove/reset the property, replace --set=<value> with --reset'
# We surround `$property` and `$value` with quotes, because they might contain special characters.{{{
#
# Like angle brackets or semicolons:
#
#                                                                  v                         v
#     $ xfconf-query --channel=xfce4-keyboard-shortcuts --property='/commands/custom/<Super>v' ...
#                                                                                    ^     ^
#
#                                                                                        v   v
#     $ xfconf-query --channel=xfce4-panel --property=/panels/panel-0/position --set='p=6;x=0;y=0'
#                                                                                    ^           ^
#}}}
set -f cmdline $(echo $cmdline | string collect)

commandline --replace $cmdline
