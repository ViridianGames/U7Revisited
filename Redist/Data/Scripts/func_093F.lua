require "U7LuaFuncs"
-- Updates an NPC’s status if in the party and a flag is set.
function func_093F(p0, p1)
    local local2

    local2 = get_party_members()
    if external_0939H(p1) and get_flag(57) and table.contains(local2, p0) then -- Unmapped intrinsic
        external_001DH(p0, p1) -- Unmapped intrinsic
    end
    return
end