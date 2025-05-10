--- Best guess: Wakes the Avatar from a bedroll, addressing them by name and updating party member states.
function func_0623(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 2 then
        var_0000 = get_player_id()
        if var_0000 ~= 356 then
            switch_talk_to(var_0000, 0)
            var_0001 = get_player_name()
            add_dialogue("\"Arise, " .. var_0001 .. ". Time to continue the quest.\"")
            hide_npc(var_0000)
        end
        var_0002 = get_party_members()
        -- Guess: sloop updates party member states
        for i = 1, 4 do
            var_0005 = {3, 4, 5, 2}[i]
            unknown_093FH(31, var_0005) --- Guess: Updates object state
        end
        unknown_0089H(1, 356) --- Guess: Sets item flag
        unknown_008AH(1, 356) --- Guess: Sets quest flag
        if get_object_type(objectref) == 1011 and get_object_frame(objectref) == 17 then
            calle_0624H(objectref, 1) --- External call to retrieve bedroll
        end
    end
end