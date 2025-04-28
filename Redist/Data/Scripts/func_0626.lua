require "U7LuaFuncs"
-- Manages object positioning for type 518, adjusting positions based on proximity and removing items as needed.
function func_0626(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    local0 = get_item_type(itemref)
    if local0 == 518 then
        external_007AH() -- Unmapped intrinsic
        local1 = add_item(-359, 6, 518, itemref)
        local2 = {}
        for local3 in ipairs(local1) do
            local4 = local3
            local5 = local4
            local2[#local2 + 1] = local5
        end
        local1 = external_093DH(local2, local1) -- Unmapped intrinsic
        local6 = get_item_data(itemref)
        local7 = 1
        for local8 in ipairs(local1) do
            local9 = local8
            local10 = get_item_data(local9)
            local11 = 1
            while local11 <= local7 do
                local12 = calculate_distance(local10[local11], local6[local11]) -- Unmapped intrinsic
                local13 = calculate_distance(local10[local11 + 1], local6[local11 + 1]) -- Unmapped intrinsic
                if local12 <= 2 and local13 <= 2 then
                    remove_item(local9)
                    local6[local11] = local10[local11]
                    local7 = local7 + 1
                else
                    local11 = local11 + 1
                end
            end
        end
        set_flag(itemref, 37)
        remove_item(itemref)
    elseif local0 == 848 or local0 == 268 then
        if get_item_frame(itemref) ~= 2 then
            local13 = add_item(itemref, {2, 17478, 7937, 37, 7768})
        end
        remove_item(itemref)
    end
    return
end