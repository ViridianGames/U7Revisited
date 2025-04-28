require "U7LuaFuncs"
-- Function 01F0: Dog NPC interaction
function func_01F0(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    -- Eventid == 1: Player interaction
    if eventid == 1 then
        _ItemSay("@Good doggy.@", -356)
        calli_001D(9, itemref)
    end

    -- Eventid == 0: Random bark
    if eventid == 0 then
        local0 = _Random2(1, 2)
        if local0 == 1 then
            _ItemSay("@Arf@", itemref)
        elseif local0 == 2 then
            _ItemSay("@Bark@", itemref)
        end
    end

    return
end