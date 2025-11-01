--- Best guess: Applies effects to party members not matching a specific NPC ID (356) with non-zero dexterity, triggering a sequence when event ID 3 is received.
function utility_event_0443(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 3 then
        var_0000 = get_object_quality(objectref)
        var_0001 = get_party_list()
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            if var_0004 ~= 356 and not roll_to_win(15, get_npc_prop(2, var_0004)) then
                halt_scheduled(var_0004)
                utility_unknown_1087(0, var_0004)
                set_attack_mode(7, var_0004)
                set_oppressor(356, var_0004)
                var_0005 = delayed_execute_usecode_array(var_0000, 1723, {17493, 7715}, var_0004)
            end
        end
    elseif eventid == 2 then
        utility_unknown_1087(31, objectref)
    end
    return
end