require "U7LuaFuncs"
-- Function 01EF: Cat NPC interaction
function func_01EF(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    -- Eventid == 1: Player interaction
    if eventid == 1 then
        _ItemSay("@Here kitty, kitty@", -356)
        calli_001D(0, itemref)
        calli_004B(7, itemref)
        calli_004C(-356, itemref)
        if not _NPCInParty(-3) then
            local0 = callis_0002(4, {"@I hate cats.@", 17490, 7715}, -3)
        end
    end

    -- Eventid == 0: Meow
    if eventid == 0 then
        _ItemSay("@Meow@", itemref)
    end

    return
end