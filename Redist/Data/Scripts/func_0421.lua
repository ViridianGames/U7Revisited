--- Best guess: Handles dialogue with Nicholas, a toddler in the Royal Nursery, engaging in tag and diaper-changing interactions, with Nanna’s commentary.
function func_0421(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if eventid == 1 then
        switch_talk_to(33, 0)
        var_0000 = unknown_08F7H(34) --- Guess: Checks player status
        add_answer({"bye", "job", "name"})
        if not get_flag(162) then
            add_dialogue("You see a child that has recently grown into toddlerhood.")
            set_flag(162, true)
        else
            add_dialogue("\"Whee! Yoooo!\" intones Nicholas.")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                if var_0000 then
                    switch_talk_to(34, 0)
                    add_dialogue("\"His name is Nicholas.\"")
                    hide_npc(34)
                    switch_talk_to(33, 0)
                else
                    add_dialogue("\"Nick-las\".")
                end
                remove_answer("name")
            elseif var_0001 == "job" then
                var_0001 = unknown_001CH(33) --- Guess: Gets object state
                if var_0001 == 25 then
                    add_dialogue("The toddler is obviously deeply engaged in a game of tag and will not stop to speak.")
                    abort()
                else
                    if var_0000 then
                        switch_talk_to(34, 0)
                        add_dialogue("\"Why, his job is to wet his diaper! Is that not right, Nicholas?\" Nanna says in baby-talk.")
                        switch_talk_to(33, 0)
                        add_dialogue("\"Whee! Dia-per!\"")
                        switch_talk_to(34, 0)
                        add_dialogue("\"Nicholas is one of our orphans. He was left in front of the castle one morning. 'Tis a sad state of affairs when this kind of thing happens.\"")
                        hide_npc(34)
                        switch_talk_to(33, 0)
                    else
                        add_dialogue("\"Whee! Dia-per!\"")
                    end
                    add_answer({"diaper", "wet"})
                end
            elseif var_0001 == "wet" then
                add_dialogue("You notice that Nicholas' diaper is wet.")
                if var_0000 then
                    switch_talk_to(34, 0)
                    add_dialogue("\"Oh, my. He's wet, is he not? Couldst thou be a dear and change him for me? I would appreciate it!\"")
                    hide_npc(34)
                end
                add_dialogue("\"Yeeee! Dia-per! Geeee!\" Nicholas says happily.")
                remove_answer("wet")
            elseif var_0001 == "diaper" then
                if var_0000 then
                    switch_talk_to(34, 0)
                    add_dialogue("\"The diapers are there on that table. If thou wouldst just use one on Nicholas...\"")
                    hide_npc(34)
                else
                    add_dialogue("Nicholas points to the diapers on the table.")
                end
                remove_answer("diaper")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"Bye bye!\"")
    elseif eventid == 0 then
        var_0001 = unknown_001CH(33) --- Guess: Gets object state
        if var_0001 == 25 then
            var_0002 = random(1, 4)
            if var_0002 == 1 then
                var_0003 = "@Tag! Thou it!@"
            elseif var_0002 == 2 then
                var_0003 = "@Catch me! Catch me!@"
            elseif var_0002 == 3 then
                var_0003 = "@Nyah nyah!@"
            elseif var_0002 == 4 then
                var_0003 = "@Tag! Whee!@"
            end
            bark(33, var_0003)
        end
    end
end