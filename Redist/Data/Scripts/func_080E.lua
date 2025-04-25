-- Checks for a blocked bridge and applies effects if conditions are met.
function func_080E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    local0 = {}
    for local1 in ipairs(local0) do
        local2 = local1
        local3 = local2
        if get_item_type(local3) == 870 then
            local4 = get_item_data(local3)
            local5 = local4[1]
            local6 = local4[2]
            local7 = local4[3]
            local8 = external_0035H(0, 10, -359, local3) -- Unmapped intrinsic
            for local9 in ipairs(local8) do
                local10 = local9
                local11 = local10
                local4 = get_item_data(local11)
                if local4[3] > local7 and local4[1] <= local5 and local4[1] >= local5 - 3 and local4[2] <= local6 and local4[2] >= local6 - 6 then
                    external_08FFH("I believe the bridge is blocked.") -- Unmapped intrinsic
                    return false
                end
            end
            local14 = add_item(local3, {34, 17496, 7937, 0, 17478, 7937, 1553, 8021, 34, 17496, 7937, 1, 8006, 34, 17496, 7937, 0, 7750})
        else
            local14 = add_item(local3, {34, 17496, 7937, 0, 8006, 34, 17496, 7937, 1, 17478, 1553, 8021, 34, 17496, 7937, 0, 7750})
        end
    end
    if array_size(local0) == 0 then -- Unmapped intrinsic
        return false
    end
    return true
end