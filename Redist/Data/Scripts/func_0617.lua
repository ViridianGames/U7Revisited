--- Best guess: Handles dialogue and item manipulation for a quest item (possibly an hourglass), instructing the Avatar to take it to Mordra.
function func_0617(eventid, objectref)
    local var_0000, var_0001

    set_flag(424, true)
    start_conversation()
    if eventid == 1 then
        var_0000 = unknown_0002H(20, {1559, 17493, 17452, 7715}, objectref) --- Guess: Adds item to container
        var_0001 = unknown_000EH(40, 747, objectref) --- Guess: Unknown item operation
        var_0000 = unknown_0002H(19, 1, {17478, 7724}, var_0001) --- Guess: Adds item to container
    elseif eventid == 2 then
        unknown_001DH(15, objectref) --- Guess: Sets object behavior
        if not npc_in_party(142) then
            switch_talk_to(142, 0)
            add_dialogue("\"There. It is done. Now take the blasted thing to Mordra. She will instruct thee in its use.\"")
            abort()
        else
            set_flag(462, true)
        end
    end
end