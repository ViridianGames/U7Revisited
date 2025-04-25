-- Adjusts an NPC’s property based on a parameter.
function func_092A(p0, p1)
    local local2, local3, local4

    if not external_0031H(p1) then -- Unmapped intrinsic
        local2 = get_npc_property(0, p1) -- Unmapped intrinsic
        local3 = get_npc_property(3, p1) -- Unmapped intrinsic
        if local3 + p0 < 1 then
            p0 = -local3
        elseif local3 + p0 > local2 then
            p0 = local2 - local3
        end
        local4 = set_npc_property(3, p1, p0) -- Unmapped intrinsic
    end
    return
end