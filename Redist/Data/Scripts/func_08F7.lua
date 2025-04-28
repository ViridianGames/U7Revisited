require "U7LuaFuncs"
-- Checks if an NPC is in the party or has a specific status.
function func_08F7(p0)
    local local1, local2

    local1 = external_001BH(p0) -- Unmapped intrinsic
    local2 = npc_in_party(local1) -- Unmapped intrinsic
    if not external_0088H(0, local1) then -- Unmapped intrinsic
        local2 = false
    end
    return local2
end