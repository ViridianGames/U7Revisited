--- Best guess: Applies effects to party members with non-zero strength, displaying random distress messages and triggering a sequence when event ID 3 is received.
function utility_event_0442(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 3 then
        var_0000 = get_party_list2()
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            if not roll_to_win(get_npc_property(0, var_0003), get_object_quality(objectref)) then
                var_0004 = get_npc_name(var_0003)
                halt_scheduled(var_0004)
                utility_unknown_0288(var_0004)
                var_0005 = delayed_execute_usecode_array(25, 1567, {17493, 7715}, var_0004)
                var_0005 = execute_usecode_array(var_0004, {8033, 4, 17447, 8046, 4, 17447, 8045, 4, 17447, 8044, 5, 17447, 7715})
                if not utility_unknown_1079(var_0004) then
                    utility_unknown_1028(var_0004, {"@Yuk!@", "@Oh no!@", "@Eeehhh!@", "@Ohh!@"})
                end
                var_0005 = delayed_execute_usecode_array(17, 1722, {17493, 7715}, var_0004)
            end
        end
    elseif eventid == 2 then
        var_0006 = 0
        var_0007 = 0
        while var_0006 < 16 do
            if var_0007 == 0 then
                var_0007 = var_0006 + die_roll(3, 0)
            else
                var_0007 = {var_0007, var_0006 + die_roll(3, 0)}
            end
            var_0006 = var_0006 + 4
        end
        for i = 1, #var_0007 do
            var_0008 = var_0007[i]
            if var_0008 then
                var_0005 = create_new_object(912)
                if var_0005 then
                    set_item_flag(18, var_0005)
                    var_000C = update_last_created(get_object_position(objectref))
                    set_object_frame(var_0008, var_0005)
                end
            end
        end
    end
    return
end