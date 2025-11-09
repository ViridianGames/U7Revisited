--- Best guess: Modifies item properties based on quality and event ID, applying random or specific effects.
function object_pool_0893(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = get_object_quality(objectref)
        var_0001 = click_on_item()
        set_object_quality(objectref, 90)
        if var_0000 == 1 then
            set_item_flag(var_0001, 1)
        elseif var_0000 == 2 then
            var_0002 = random2(10, 1)
            var_0003 = 13 - var_0002
            utility_unknown_1066(var_0001, var_0003)
        elseif var_0000 == 3 then
            clear_item_flag(var_0001, 8)
            clear_item_flag(var_0001, 7)
            clear_item_flag(var_0001, 1)
            clear_item_flag(var_0001, 2)
            clear_item_flag(var_0001, 3)
        elseif var_0000 == 4 then
            set_item_flag(var_0001, 8)
        elseif var_0000 == 5 then
            clear_item_flag(var_0001, 1)
        elseif var_0000 == 6 then
            set_item_flag(var_0001, 9)
        elseif var_0000 == 7 then
            cause_light(100)
        elseif var_0000 == 8 then
            set_item_flag(var_0001, 0)
        end
    end
    return
end