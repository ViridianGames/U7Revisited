require "U7LuaFuncs"
-- Calculates a value based on an NPC’s property.
function func_08F6(p0)
    local local1, local2, local3

    local1 = external_001BH(p0) -- Unmapped intrinsic
    local2 = math.floor(get_npc_property(8, local1) / 100) -- Unmapped intrinsic
    local3 = 1
    while local2 > 0 do
        local3 = local3 + 1
        local2 = math.floor(local2 / 2)
    end
    return local3
end