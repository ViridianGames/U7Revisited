--- Best guess: Manages a spinning wheel, checking for wool (type 873) to produce thread (type 653), with a message if empty, and updating item frame randomly.
function object_spinningwheel_0651(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 7 then
        var_0000 = find_nearby(0, 1, 873, -356)
        var_0001 = 0
        if #var_0000 > 0 then
            var_0002 = execute_usecode_array({12, -1, 17419, 17515, 8044, 6, 7769}, -356)
            var_0001 = 3
        end
        halt_scheduled(objectref)
        var_0002 = delayed_execute_usecode_array(objectref, {var_0001, 651, 8021, 12, -4, 7947, 6, 17496, 17409, 8014, 0, 7750})
    elseif eventid == 2 then
        var_0003 = get_cont_items(-359, -359, 653, -356)
        if var_0003 then
            remove_item(var_0003)
        end
        var_0004 = create_new_object(654)
        if var_0004 then
            set_item_flag(18, var_0004)
            set_item_flag(11, var_0004)
            set_object_frame(math.random(0, 9), var_0004)
            var_0005 = get_object_position(objectref)
            var_0005[1] = var_0005[1] + 1
            var_0005[2] = var_0005[2] + 1
            var_0002 = update_last_created(var_0005)
        end
    elseif eventid == 1 then
        var_0006 = "@I suspect spinning the wool will be more fruitful than spinning an empty wheel.@"
        utility_unknown_1023(var_0006, objectref)
    end
    return
end