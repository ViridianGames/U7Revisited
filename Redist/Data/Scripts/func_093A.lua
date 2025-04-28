require "U7LuaFuncs"
-- Resets NPC status effects and converts specific items.
function func_093A(p0, p1)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    local2 = external_008DH() -- Unmapped intrinsic
    for local3, local4 in ipairs(p1) do
        local5 = local4
        if get_npc_property(9, local5) >= 10 then -- Unmapped intrinsic
            if local5 ~= -356 then
                external_008AH(1, local5) -- Unmapped intrinsic
            end
            external_008AH(8, local5) -- Unmapped intrinsic
            external_008AH(7, local5) -- Unmapped intrinsic
            external_008AH(3, local5) -- Unmapped intrinsic
            external_008AH(2, local5) -- Unmapped intrinsic
            external_008AH(0, local5) -- Unmapped intrinsic
            external_008AH(9, local5) -- Unmapped intrinsic
            external_093BH(p0, 0, 3, local5) -- Unmapped intrinsic
            external_093BH(-p0, 6, 5, local5) -- Unmapped intrinsic
            local6 = set_npc_property(9, local5, -p0) -- Unmapped intrinsic
        end
    end
    local7 = external_0035H(0, 30, 701, p0) -- Unmapped intrinsic
    local7 = external_0035H(0, 30, 338, p0) -- Unmapped intrinsic
    for local8, local9 in ipairs(local7) do
        local10 = local9
        local11 = get_item_quality(local10) -- Unmapped intrinsic
        if local11 <= 30 * p1 then
            external_005CH(local10) -- Unmapped intrinsic
            local12 = get_item_type(local10) -- Unmapped intrinsic
            if local12 == 338 then
                set_item_type(local10, 997) -- Unmapped intrinsic
            elseif local12 == 701 then
                set_item_type(local10, 595) -- Unmapped intrinsic
            end
            local6 = external_0015H(local10, 255) -- Unmapped intrinsic
        else
            local6 = external_0015H(local10, local11 - 30 * p1) -- Unmapped intrinsic
        end
    end
    return
end