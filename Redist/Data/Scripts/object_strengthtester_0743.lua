--- Best guess: Manages a dragon encounter, rewarding the Avatar with a win message and triggering state changes, possibly for a quest.
function object_strengthtester_0743(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        -- calli 007E, 0 (unmapped)
        close_gumps()
        var_0000 = {1, -1, 0}
        var_0001 = {1, 1, 1}
        var_0002 = -1
        -- call [0000] (0828H, unmapped)
        utility_position_0808(7, objectref, 743, var_0002, var_0001, var_0000, objectref)
    elseif eventid == 7 then
        -- call [0001] (0827H, unmapped)
        var_0003 = utility_unknown_0807(objectref, 356)
        var_0004 = execute_usecode_array(356, {17505, 17516, 8449, var_0003, 7769})
        var_0005 = get_npc_property(356, 0)
        if var_0005 >= 0 and var_0005 < 4 then
            var_0005 = 0
        elseif var_0005 >= 4 and var_0005 < 8 then
            var_0005 = 1
        elseif var_0005 >= 8 and var_0005 < 12 then
            var_0005 = 2
        elseif var_0005 >= 12 and var_0005 < 15 then
            var_0005 = 3
        elseif var_0005 >= 15 and var_0005 < 18 then
            var_0005 = 4
        elseif var_0005 >= 18 and var_0005 < 23 then
            var_0005 = 5
        elseif var_0005 >= 23 and var_0005 < 30 then
            var_0005 = 6
        elseif var_0005 >= 30 then
            var_0005 = 7
        end
        if var_0005 > 3 then
            var_0005 = var_0005 - random2(2, 0)
        end
        if var_0005 == 7 then
            var_0005 = 6
        end
        if var_0005 > 7 then
            var_0004 = delayed_execute_usecode_array(objectref, {var_0005 + 1, 24, 7715})
            if not npc_id_in_party(44) and not utility_unknown_1079(44) then
                bark(44, "@Avatar wins a Dragon!@")
                var_0004 = add_party_items(false, 0, 359, 742, 1)
            end
        end
        var_0004 = execute_usecode_array(objectref, {0, 8518, var_0005, -1, 17419, 8527, var_0005, -1, 17419, 8013, 4, 8024, 0, 7750})
    end
    return
end