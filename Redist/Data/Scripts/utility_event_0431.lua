--- Best guess: Applies a sleep effect to party members in a poppy field when event ID 3 is triggered, if their strength is not zero.
function utility_event_0431(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 3 then
        play_sound_effect(28)
        var_0000 = get_party_list2()
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            if not roll_to_win(get_npc_prop(0, var_0003), get_object_quality(objectref)) then
                var_0004 = get_npc_name(var_0003)
                utility_unknown_0288(var_0004)
                set_item_flag(1, var_0004)
                var_0005 = delayed_execute_usecode_array(100, 1567, {17493, 7715}, var_0004)
            end
        end
    end
    return
end