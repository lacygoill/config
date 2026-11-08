-- https://wiki.archlinux.org/title/XScreenSaver#mpv
local utils = require 'mp.utils'
mp.add_periodic_timer(30, function()
  if not mp.get_property_native('pause') then
    utils.subprocess({args={'xscreensaver-command', '--deactivate'}})
  end
end)
