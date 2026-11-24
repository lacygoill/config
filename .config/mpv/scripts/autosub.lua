-- Source: https://gist.github.com/selsta/ce3fb37e775dbd15c698

-- This script works (tested with “A bridge of spies”).
-- However, it can take some time (several minutes).

-- Alternative: https://github.com/directorscut82/find_subtitles

-- requires subliminal, version 1.0 or newer (install from your repo or via pip)
-- default keybinding: M-s
-- add the following to your input.conf to change the default keybinding:
--
--     <key> script_binding auto_load_subs

local utils = require 'mp.utils'
function load_sub_fn()
    -- we need the path to `subliminal`

    -- read the output of `$ which subliminal`{{{
    --
    --     https://stackoverflow.com/a/9676174/9780968
    --
    -- Don't add `sub:close()` like in the answer.
    -- It would break the code.
    --}}}
    subl = io.popen("which subliminal")
    subl = subl:read("*all")
    -- remove the trailing newline
    --     https://stackoverflow.com/a/24799170/9780968
    subl = subl:sub(1,-2)

    -- There was no `for` loop in the original code.
    -- It only cared about english.
    -- For the syntax of this loop, see:
    --     https://stackoverflow.com/a/7617366/9780968
    langs = {"fr", "en"}
    for i, lang in ipairs(langs) do
        mp.msg.info("Searching subtitle")
        mp.osd_message("Searching subtitle")
        t = {}
        -- Original code:{{{
        --
        --     t.args = {subl, "download", "-s", "-l", "en", mp.get_property("path")}
        --                                  ^^
        --                                  remove that shit!
        --
        -- If you use an old version of `subliminal`, try this instead:
        --
        --     $ /usr/bin/subliminal -l en -- /path/to/file
        --}}}
        t.args = {subl, "download", "-l", lang, mp.get_property("path")}
        res = utils.subprocess(t)
        if res.status == 0 then
            mp.commandv("rescan_external_files", "reselect")
            mp.msg.info("Subtitle download succeeded")
            mp.osd_message("Subtitle download succeeded")
        else
            mp.msg.warn("Subtitle download failed")
            mp.osd_message("Subtitle download failed")
        end
    end
end

mp.add_key_binding("alt+s", "auto_load_subs", load_sub_fn)
