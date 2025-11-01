--- Best guess: Handles dialogue with Rowena, a ghostly lady in Horance's tower on Skara Brae, discussing her role as mistress, her lord Horance (the Liche), and the tower's beauty. Includes conditional ghostly behavior based on player actions and time of day.
function npc_rowena_0144(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if eventid == 1 then
        if not get_flag(440) then
            switch_talk_to(144, 0)
            add_dialogue("The beautiful ghost looks through you with a slack look. Nothing you do seems to attract her attention.")
            set_flag(423, false)
            abort()
        end
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        var_0000 = is_player_female()
        var_0001 = get_lord_or_lady()
        if not get_flag(422) then
            switch_talk_to(144, 1)
            utility_unknown_0982() --- Guess: Initiates follow behavior
        end
        if not get_flag(426) then
            switch_talk_to(144, 1)
            utility_music_0983() --- Guess: Sets follow behavior
        end
        if not get_flag(423) and not get_flag(425) then
            switch_talk_to(144, 1)
            utility_unknown_0984() --- Guess: Checks ring status
        end
        var_0002 = get_schedule() --- Guess: Checks game state
        var_0003 = get_schedule_type(144) --- Guess: Gets schedule
        if var_0002 == 0 or var_0002 == 1 then
            if var_0003 == 14 then
                switch_talk_to(144, 0)
                utility_unknown_0985() --- Guess: Triggers sleep event
            elseif var_0003 ~= 16 then
                switch_talk_to(144, 0)
                utility_unknown_0986() --- Guess: Triggers other event
            end
        end
        switch_talk_to(144, 0)
        if not get_flag(457) then
            add_dialogue("You see a ghostly lady wearing a long, black gown. Something is a bit strange about the way she looks, but you can't quite place it. After a pause, she says, \"Greetings, " .. var_0001 .. ". I am Rowena, lady of this wondrous tower.\" She gestures around the room, indicating the moldering walls and cobwebbed rafters.")
            set_flag(457, true)
        else
            add_dialogue("Rowena smiles in an abstract manner as you approach. \"Ah, thou hast returned, " .. var_0001 .. ". How may the lady of the tower be of assistance to thee?\"")
        end
        add_answer({"bye", "tower", "job", "name"})
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("\"I am called... Rowena\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                add_dialogue("She stares blankly for a second, then, as if on cue, \"I am the Mistress of the Tower. I tend to my Lord Horance's needs and keep our place looking respectable.\" It would appear that she's been falling behind in the latter duty.")
                add_answer("Horance")
            elseif var_0004 == "tower" then
                add_dialogue("After a moment, \"This is a lovely tower, dost thou not agree?\" Before you can answer, she continues.")
                add_dialogue("\"Dost thou see the lovely rays of light playing across the flagstones of the floor? Water sparkles in the fountain. This is truly a beautiful place in which to live.\" Her eyes fix upon the floor.")
                remove_answer("tower")
            elseif var_0004 == "Horance" then
                add_dialogue("She blinks once, then, \"Horance... What a wonderful name. He found me lost and lonely and brought me here to be a lady. Is he not truly the most magnificent of Lords?\"")
                remove_answer("Horance")
            elseif var_0004 == "bye" then
                add_dialogue("She pauses. \"Goodbye, " .. var_0001 .. ". I hope thou hast enjoyed thy visit to our glorious tower. Please, return whenever thou wishest.\" You feel as if you've been speaking to a statue.")
                abort()
            end
        end
    elseif eventid == 0 then
        abort()
    end
end