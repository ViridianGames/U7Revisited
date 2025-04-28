require "U7LuaFuncs"
-- Manages horse movement in a race, adjusting positions and frames based on random events and race state.
function func_060D(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17

    if eventid == 2 then
        return
    end

    local0 = add_item(0, 10, 410, itemref)
    local1 = get_item_quality(local0)
    local2 = {915, 916, 914}
    local3 = local2[local1 + 1]
    if get_random(1, 20) == 1 then
        local4 = get_item_data(itemref)
        local5 = add_item(local3, 644)
        if local5 then
            set_schedule(local5, 18)
            set_item_frame(local5, 0)
            set_item_owner({local4[1], local4[2] - 9, local4[3]}, local5)
        end
    end

    local7 = add_item(0, 10, -359, itemref)
    local8 = get_item_data(itemref)
    local9 = local8[1]
    local10 = local8[2]
    for local11 in ipairs(local7) do
        local12 = local11
        local13 = get_item_data(local12)
        local14 = local13[1]
        local15 = local13[2]
        local16 = local13[3]
        if local14 <= local9 and local15 == local10 and local16 == 1 then
            local17 = remove_item(local12)
            if local17 then
                set_item_owner({local16, local15, local14 + 1}, local12)
            end
        elseif local14 == local9 + 1 and local15 == local10 and local16 == 1 then
            local17 = remove_item(local12)
            if local17 then
                set_item_owner({0, local15, local14}, local12)
            end
        end
    end

    return
end