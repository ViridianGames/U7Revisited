--- Best guess: Checks for bridge-blocking items (ID 870) within a radius, displaying a message if blocked, and creates items (ID 1553) with specific properties.
function utility_unknown_0782(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    for var_0000 in ipairs(get_party_members()) do
        if get_object_shape(var_0003) == 870 then
            var_0004 = get_object_position(var_0003)
            var_0005 = var_0004[1]
            var_0006 = var_0004[2]
            var_0007 = var_0004[3]
            var_0008 = find_nearby(0, 10, -359, var_0003)
            for var_0009 in ipairs(var_0008) do
                var_0004 = get_object_position(var_000B)
                if var_0004[3] > var_0007 and var_0004[1] <= var_0005 and var_0004[1] >= var_0005 - 3 and var_0004[2] <= var_0006 and var_0004[2] >= var_0006 - 6 then
                    utility_unknown_1023("I believe the bridge is blocked.")
                    return false
                end
            end
        end
        var_000E = execute_usecode_array(var_0003, {34, 17496, 7937, 0, 8006, 34, 17496, 7937, 1, 17478, 1553, 8021, 34, 17496, 7937, 0, 7750})
    end
    return #var_0000 == 0
end