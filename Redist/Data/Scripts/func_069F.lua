-- Processes items in an area, updating their type and frame based on quality and frame conditions.
function func_069F(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16

    local0 = external_0035H(16, 10, 275, itemref) -- Unmapped intrinsic
    for local1 in ipairs(local0) do
        local2 = local1
        local3 = local2
        local4 = get_item_quality(local3)
        local5 = get_item_frame(local3)
        local6 = get_item_data(local3)
        if local5 == 6 then
            if local4 == 0 then
                local7 = 3
                local8 = {{2183, 1}, {1525, 2}, {0, 3}}
                external_087EH(local3, local6, local7, local8) -- Unmapped intrinsic
                local9 = get_item_by_type(739) -- Unmapped intrinsic
                set_item_frame(local9, 4)
                local10 = set_item_data(local6)
            elseif local4 == 1 then
                local7 = 1
                local8 = {{2188, 1}, {1527, 2}, {0, 3}}
                external_087EH(local3, local6, local7, local8) -- Unmapped intrinsic
                local11 = get_item_by_type(431) -- Unmapped intrinsic
                set_item_frame(local11, 3)
                local10 = set_item_data(local6)
                create_object(-1, 0, 0, 0, local6[2] - 1, local6[1] - 4, 13) -- Unmapped intrinsic
            elseif local4 == 2 then
                local7 = 2
                local8 = {{2187, 1}, {1521, 2}, {0, 3}}
                external_087EH(local3, local6, local7, local8) -- Unmapped intrinsic
                local12 = get_item_by_type(991) -- Unmapped intrinsic
                set_item_frame(local12, 1)
                local10 = set_item_data(local6)
            elseif local4 == 4 then
                local7 = 3
                local8 = {{2193, 1}, {1520, 2}, {0, 3}}
                external_087EH(local3, local6, local7, local8) -- Unmapped intrinsic
                local13 = get_item_by_type(741) -- Unmapped intrinsic
                set_item_frame(local13, 4)
                local10 = set_item_data(local6)
                create_object(-1, 0, 0, 0, local6[2] - 1, local6[1] - 5, 13) -- Unmapped intrinsic
            elseif local4 == 5 then
                local7 = 3
                local8 = {{2196, 1}, {1526, 2}, {0, 3}}
                external_087EH(local3, local6, local7, local8) -- Unmapped intrinsic
                local14 = get_item_by_type(470) -- Unmapped intrinsic
                set_item_frame(local14, 1)
                local10 = set_item_data(local6)
                create_object(-1, 0, 0, 0, local6[2] - 2, local6[1] - 2, 13) -- Unmapped intrinsic
            elseif local4 == 6 then
                local7 = 3
                local8 = {{2200, 1}, {1523, 2}, {0, 3}}
                local15 = external_087EH(local3, local6, local7, local8) -- Unmapped intrinsic
                local16 = get_item_by_type(740) -- Unmapped intrinsic
                set_item_frame(local16, 12)
                local10 = set_item_data(local6)
            end
        end
    end
    local16 = add_item(itemref, {1696, 8021, 5, 17447, 8033, 4, 17447, 8048, 5, 7719})
    apply_effect(67) -- Unmapped intrinsic
    return
end