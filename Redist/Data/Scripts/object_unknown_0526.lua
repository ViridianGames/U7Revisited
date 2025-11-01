--- Best guess: Checks proximity of a light source (type 440) to an item, transforming it (type 889) if conditions are met, likely for a light-based puzzle.
function object_unknown_0526(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 or eventid == 2 then
        set_object_shape(objectref, 889)
        -- var_0000 = find_nearby(128, 10, 440, objectref)
        -- var_0001 = get_object_position(objectref)
        -- var_0001[1] = var_0001[1] + 3
        -- var_0001[2] = var_0001[2] + 3
        -- for _, var_0004 in ipairs(var_0000) do
        --     var_0005 = get_object_position(var_0004)
        --     if var_0001[1] == var_0005[1] and var_0001[2] == var_0005[2] and var_0001[3] == var_0005[3] then
        --         remove_item(var_0004)
        --         set_item_shape(889, objectref)
        --         set_object_quality(objectref, 46)
        --     end
        -- end
    end
    --return
end