require "U7LuaFuncs"
-- Applies damage to an NPC based on their strength and health.
function func_0689(eventid, itemref)
    local local0, local1

    local0 = get_npc_property(itemref, 2)
    local1 = get_npc_property(itemref, 3)
    if external_004AH(local0, 16) then -- Unmapped intrinsic
        external_0936H(itemref, local1 - 1) -- Unmapped intrinsic
        external_0936H(itemref, 50) -- Unmapped intrinsic
    end
    return
end