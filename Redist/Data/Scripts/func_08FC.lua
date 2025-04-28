require "U7LuaFuncs"
-- Checks if an NPC’s level is below a threshold.
function func_08FC(p0, p1)
    local local2

    local2 = external_0019H(p0, p1) -- Unmapped intrinsic
    if local2 < 20 then
        return true
    end
    return false
end