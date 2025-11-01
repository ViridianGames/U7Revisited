--- Best guess: Handles pig NPC dialogue, saying "Oink" or performing actions based on flags.
function utility_unknown_1027(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if not npc_in_party(arg1) then --- Guess: Checks if NPC is in party
        var_0002 = arg1 == 356 and is_player_female() or 0 --- Guess: Checks player gender
        switch_talk_to(var_0002, arg1) --- Guess: Initiates dialogue
        if not check_object_flag(objectref, 25) then --- Guess: Checks item flag
            add_dialogue("@Oink@")
        else
            for _, var_0005 in ipairs({3, 4, 5, 0}) do
                add_dialogue(var_0005 .. "") --- Guess: Says action value
            end
        end
        hide_npc(arg1) --- Guess: Hides NPC
    end
end