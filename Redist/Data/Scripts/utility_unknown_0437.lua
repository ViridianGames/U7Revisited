--- Best guess: Manages an egg in a blacksmith's house, checking nearby items (types 270, 376) and triggering external functions based on their properties.
function utility_unknown_0437(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 3 then
        var_0000 = find_nearby(0, 40, 270, objectref)
        var_0000 = find_nearby(0, 40, 376, objectref)[var_0000]
        var_0001 = {}
        for i = 1, #var_0000 do
            var_0001 = get_distance(var_0001, var_0000[i], objectref)
        end
        var_0000 = utility_unknown_1085(var_0001, var_0000)
        var_0005 = 1
        while var_0005 <= #var_0000 do
            var_0004 = var_0000[var_0005]
            if var_0004 then
                if utility_unknown_0795(var_0004) == 2 then
                    var_0005 = var_0005 + 1
                else
                    var_0006 = get_item_shape(var_0004)
                    if var_0006 == 270 then
                        object_door_0270(var_0004)
                    elseif var_0006 == 376 then
                        object_door_0376(var_0004)
                    end
                    break
                end
            else
                break
            end
        end
    end
    return
end