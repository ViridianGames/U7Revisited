require "U7LuaFuncs"
-- Manages winch operations, checking bridge and gangplank states.
function func_083E(p0, p1)
    local local2, local3, local4, local5, local6, local7, local8

    if p0 == 1 then
        if not external_0079H(p1) then -- Unmapped intrinsic
            external_0828H(7, p1, -2, -2, p1, 1585) -- Unmapped intrinsic
        end
    elseif p0 == 2 then
        local2 = get_item_quality(itemref)
        local3 = external_0035H(0, 15, 870, itemref) -- Unmapped intrinsic
        local4 = external_0035H(0, 15, 515, itemref) -- Unmapped intrinsic
        local3 = array_append(local3, local4)
        local4 = {}
        for local5 in ipairs(local3) do
            local6 = local5
            local7 = local6
            if get_item_quality(local7) == local2 then
                local4 = array_append(local4, local7)
            end
        end
        if not external_080EH(local4) then -- Unmapped intrinsic
            local8 = add_item(itemref, {4, -1, 17419, 8014, 1, 7750})
        elseif not get_flag(61) then
            external_083FH(false, itemref) -- Unmapped intrinsic
        end
    end
    return
end