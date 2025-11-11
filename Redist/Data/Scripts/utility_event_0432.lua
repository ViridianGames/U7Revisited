--- Best guess: Applies a poison effect to party members when event ID 3 is triggered, if their strength is not zero, likely in a toxic area.
function utility_event_0432(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        play_sound_effect(28)
        var_0000 = get_party_list2()
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            if not roll_to_win(get_npc_property(0, var_0003), get_object_quality(objectref)) then
                set_item_flag(8, get_npc_name(var_0003))
            end
        end
    end
    return
end