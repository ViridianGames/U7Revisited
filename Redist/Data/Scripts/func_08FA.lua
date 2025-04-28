require "U7LuaFuncs"
-- Checks NPC status and applies effects if conditions are met.
function func_08FA(p0)
    if not external_0088H(11, p0) and not external_0088H(23, p0) then -- Unmapped intrinsic
        external_007AH() -- Unmapped intrinsic
        external_0633H(p0) -- Unmapped intrinsic
    end
    return
end