require "U7LuaFuncs"
-- Function 02FB: Time-based NPC action
function func_02FB(eventid, itemref)
    if eventid == 1 and not callis_0079(itemref) then
        if _GetTimeHour() >= 15 or _GetTimeHour() <= 3 then
            calli_001D(9, -232)
        end
        call_082FH()
    end
    return
end