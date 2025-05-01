-- Manipulates NPC properties and triggers actions based on property values, likely related to NPC health or status, ending with a message indicating poor health.
function func_0603(eventid, itemref)
    local local0, local1, local2, local3

    set_npc_property(itemref, -6, 0)
    set_npc_property(itemref, -6, 1)
    set_npc_property(itemref, -6, 2)
    local1 = get_npc_property(itemref, 0)
    local2 = get_npc_property(itemref, 0)
    local3 = get_npc_property(itemref, 0)

    if local1 < 1 then
        external_0835(itemref, 1, 0) -- Unmapped intrinsic
    end
    if local2 < 1 then
        external_0835(itemref, 1, 2) -- Unmapped intrinsic
    end
    if local3 < 1 then
        external_0835(itemref, 1, 1) -- Unmapped intrinsic
    end

    bark(itemref, "@Thou dost not look well.@")
    return
end