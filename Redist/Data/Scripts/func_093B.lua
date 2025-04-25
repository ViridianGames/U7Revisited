-- Adjusts an NPC’s property based on a value and bounds.
function func_093B(p0, p1, p2, p3)
    local local4, local5, local6

    local4 = get_npc_property(p2, p3) -- Unmapped intrinsic
    local5 = local4 + p0 * 2
    if local5 > get_npc_property(p1, p3) then -- Unmapped intrinsic
        local5 = get_npc_property(p1, p3) -- Unmapped intrinsic
    end
    local6 = set_npc_property(p2, p3, local5 - local4) -- Unmapped intrinsic
    return
end