require "U7LuaFuncs"
-- Generates another random phrase for mad-libs style dialogue.
function func_086B()
    local local0, local1, local2

    local0 = {"without my knowledge", "without the proper documentation", "though the ages", "against all odds", "with your mother", "in a roundabout manner", "implicitly", "explicitly", "anxiously"}
    local1 = get_random(1, #local0)
    local2 = local0[local1]
    return local2
end