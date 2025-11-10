--- Best guess: Handles dialogue and item manipulation for a quest item (possibly an hourglass), instructing the Avatar to take it to Mordra.
function utility_unknown_0279(eventid, objectref)
    local var_0000, var_0001

    set_flag(424, true)
    start_conversation()
    if eventid == 1 then
        var_0000 = delayed_execute_usecode_array(20, {1559, 17493, 17452, 7715}, objectref) --- Guess: Adds item to container
        var_0001 = find_nearest(40, 747, objectref) --- Guess: Unknown item operation
        var_0000 = delayed_execute_usecode_array(19, 1, {17478, 7724}, var_0001) --- Guess: Adds item to container
    elseif eventid == 2 then
        set_schedule_type(15, objectref) --- Guess: Sets object behavior
        if not npc_id_in_party(142) then
            switch_talk_to(142)
            add_dialogue("\"There. It is done. Now take the blasted thing to Mordra. She will instruct thee in its use.\"")
            abort()
        else
            set_flag(462, true)
        end
    end
end