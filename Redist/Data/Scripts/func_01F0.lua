-- Function 01F0: Dog NPC interaction
function func_01F0(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    -- Eventid == 1: Player interaction
    if eventid == 1 then
        bark(356, "@Good doggy.@")
        calli_001D(9, itemref)
    end

    -- Eventid == 0: Random bark
    if eventid == 0 then
        local0 = _Random2(1, 2)
        if local0 == 1 then
            bark(itemref, "@Arf@")
        elseif local0 == 2 then
            bark(itemref, "@Bark@")
        end
    end

    return
end