-- Triggers NPC dancing behavior, setting flags and applying effects.
function func_0688(eventid, itemref)
    if eventid == 2 then
        external_093FH(itemref, 12) -- Unmapped intrinsic
        external_008AH(itemref, 15) -- Unmapped intrinsic
    end
    return
end