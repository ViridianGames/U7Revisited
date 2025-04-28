require "U7LuaFuncs"
-- Function 011C: Manages sundial time display
function func_011C(itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid() == 1 then
        local0 = callis_0038()
        if local0 >= 6 and local0 <= 11 then
            callis_0040(" " .. local0 .. " o'clock", itemref)
        elseif local0 == 12 then
            callis_0040("Noon", itemref)
        elseif local0 >= 13 and local0 <= 20 then
            local0 = local0 - 12
            callis_0040(" " .. local0 .. " o'clock", itemref)
        else
            local1 = call_0908H()
            call_08FFH("@^<Avatar>, I believe the key word in sundial is `sun'.@")
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end