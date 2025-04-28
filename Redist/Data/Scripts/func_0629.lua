require "U7LuaFuncs"
-- Manages beer tap interactions, adjusting frames and creating items, similar to func_0628 but with different frame ranges.
function func_0629(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    local0 = get_item_frame(912)
    if local0 then
        set_flag(local0, 18)
        set_item_frame(local0, get_random(20, 23))
        local1 = get_item_data(itemref)
        local2 = add_item(itemref, 0, 2, 810)
        for local3 in ipairs(local2) do
            local4 = local3
            local5 = local4
            local6 = get_item_data(local5)
            if local6[1] == local1[1] + 1 and local6[2] == local1[2] - 1 and local6[3] == local1[3] then
                if get_item_frame(local5) == 0 then
                    set_item_frame(local5, 3)
                    local7 = add_item(itemref, 16, 1577, {7765})
                end
            end
        end
        local1[1] = local1[1] + get_random(1, 2) - 2
        local1[2] = local1[2] - get_random(0, 2) + 1
        set_item_data(local1)
        local8 = get_random(1, 2)
        if local8 == 1 then
            external_08FEH("@Turn it off!@") -- Unmapped intrinsic
        elseif local8 == 2 then
            external_08FEH("@Thou art wasting it!@") -- Unmapped intrinsic
        end
        local7 = add_item(itemref, 16, 1577, {7765})
    end
    return
end