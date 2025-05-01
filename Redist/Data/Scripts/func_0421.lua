-- Manages Nicholas's dialogue in Britain, covering toddler tag game, diaper-changing, and orphaned status.
function func_0421(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        switch_talk_to(33, 0)
        local0 = get_item_type(-34)

        add_answer({"bye", "job", "name"})

        if not get_flag(162) then
            say("You see a child that has recently grown into toddlerhood.")
            set_flag(162, true)
        end
        say("\"Whee! Yoooo!\" intones Nicholas.")

        while true do
            local answer = get_answer()
            if answer == "name" then
                if local0 then
                    switch_talk_to(34, 0)
                    say("\"His name is Nicholas.\"")
                    hide_npc(34)
                    switch_talk_to(33, 0)
                else
                    say("\"Nick-las\".")
                end
                remove_answer("name")
            elseif answer == "job" then
                local1 = check_item_state(-33)
                if local1 == 25 then
                    say("The toddler is obviously deeply engaged in a game of tag and will not stop to speak.*")
                    return
                elseif local0 then
                    switch_talk_to(34, 0)
                    say("\"Why, his job is to wet his diaper! Is that not right, Nicholas?\" Nanna says in baby-talk.")
                    switch_talk_to(33, 0)
                    say("\"Whee! Dia-per!\"")
                    switch_talk_to(34, 0)
                    say("\"Nicholas is one of our orphans. He was left in front of the castle one morning. 'Tis a sad state of affairs when this kind of thing happens.\"")
                    hide_npc(34)
                    switch_talk_to(33, 0)
                else
                    say("\"Whee! Dia-per!\"")
                end
                add_answer({"diaper", "wet"})
            elseif answer == "wet" then
                say("You notice that Nicholas' diaper is wet.")
                if local0 then
                    switch_talk_to(34, 0)
                    say("\"Oh, my. He's wet, is he not? Couldst thou be a dear and change him for me? I would appreciate it!\"")
                    hide_npc(34)
                end
                say("\"Yeeee! Dia-per! Geeee!\" Nicholas says happily.")
                remove_answer("wet")
            elseif answer == "diaper" then
                if local0 then
                    switch_talk_to(34, 0)
                    say("\"The diapers are there on that table. If thou wouldst just use one on Nicholas...\"")
                    hide_npc(34)
                else
                    say("Nicholas points to the diapers on the table.")
                end
                remove_answer("diaper")
            elseif answer == "bye" then
                say("\"Bye bye!\"*")
                break
            end
        end
    elseif eventid == 0 then
        local1 = switch_talk_to(33)
        local2 = check_item_state(-33)
        if local2 == 25 then
            local3 = random(1, 4)
            if local3 == 1 then
                local2 = "@Tag! Thou it!@"
            elseif local3 == 2 then
                local2 = "@Catch me! Catch me!@"
            elseif local3 == 3 then
                local2 = "@Nyah nyah!@"
            elseif local3 == 4 then
                local2 = "@Tag! Whee!@"
            end
            item_say(local2, -33)
        end
    end
    return
end