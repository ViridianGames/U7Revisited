require "U7LuaFuncs"
-- Retrieves the name of an NPC.
function func_090F(p0)
    return get_player_name(external_001BH(p0)) -- Unmapped intrinsic
end