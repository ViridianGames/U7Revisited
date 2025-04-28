require "U7LuaFuncs"
-- Prompts for a party member or "Nobody" and returns the selected NPC ID.
function func_090D()
    local local0, local1, local2, local3, local4

    local0 = external_08FBH() -- Unmapped intrinsic
    local1 = get_party_members()
    local2 = {unpack(local1), 0}
    local3 = external_090CH({"Nobody", unpack(local0)}) -- Unmapped intrinsic
    local4 = local3 == 1 and 0 or local2[local3 - 1]
    return external_003AH(local4) -- Unmapped intrinsic
end