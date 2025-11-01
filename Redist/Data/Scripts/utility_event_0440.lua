--- Best guess: Applies effects to party members with non-zero strength when event ID 3 is triggered, potentially paralyzing them and triggering a sequence.
function utility_event_0440(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 3 then
        var_0000 = get_party_list()
        var_0001 = get_item_quality(objectref)
        for i = 1, #var_0000 do
            var_0004 = var_0000[i]
            var_0005 = get_npc_prop(0, var_0004)
            if not roll_to_win(15, var_0005) then
                var_0006 = get_npc_name(var_0004)
                utility_unknown_0288(var_0006)
                var_0007 = delayed_execute_usecode_array(var_0001, 1567, {7765}, var_0006)
                halt_scheduled(var_0004)
                utility_unknown_1087(4, var_0004)
                var_0007 = delayed_execute_usecode_array(var_0001, 1720, {17493, 7715}, var_0004)
            end
        end
    elseif eventid == 2 then
        utility_unknown_1087(31, objectref)
    end
    return
end