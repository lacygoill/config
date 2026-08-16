-- Source:
--     https://github.com/zc62/mpv-scripts/blob/master/autoloop.lua

-- mpv issue 5222
-- Automatically set loop-file=inf for duration < given length. Default is 10s
-- Use script-opts=autoloop-duration=x in mpv.conf to set your preferred length

local autoloop_duration = 10

function getOption()
    local opt = mp.get_opt("autoloop-duration")
    if (opt ~= nil) then
        local test = tonumber(opt)
        if (test ~= nil) then
            autoloop_duration = test
        end
    end
end
getOption()

local was_loop = mp.get_property_native("loop-file")

function set_loop()
    -- This block was not there originally.{{{
    --
    -- I've added to support gif files.
    -- Indeed, for some reason, `mp.get_property_native("duration")`
    -- evaluates to `nil` instead of the duration of a gif file.
    -- So, we ask to loop a gif file UNconditionally.
    --}}}
    local format = mp.get_property_native("file-format")
    if format == "gif" then
        mp.command("set loop-file inf")
        return
    end

    local duration = mp.get_property_native("duration")
    if duration ~= nil then
        if duration  < autoloop_duration + 0.001 then
            mp.command("set loop-file inf")
        else
            mp.set_property_native("loop-file", was_loop)
        end
    else
        mp.set_property_native("loop-file", was_loop)
    end
end

mp.register_event("file-loaded", set_loop)
