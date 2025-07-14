--- Best guess: Handles dialogue with Dell, the Trinsic shopkeeper, discussing his shop, the Fellowship, and the local murder, with options to buy items during business hours.
function func_0412(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    start_conversation()
    if eventid == 1 then
        switch_talk_to(18, 0)
        var_0000 = get_schedule_time() --- Guess: Checks game state or timer
        var_0001 = get_lord_or_lady()
        var_0002 = get_player_name()
        var_0003 = get_schedule(18) --- Guess: Gets object state
        var_0004 = "Avatar"
        var_0005 = get_schedule(18) == 16 --- Guess: Checks time for Fellowship meeting
        if var_0000 == 7 then
            if var_0005 then
                add_dialogue("Dell frowns at you for distracting him during the Fellowship meeting.")
            else
                add_dialogue("\"I do not have time to talk with thee! I must get to the meeting of The Fellowship! Come to my shop tomorrow!\"")
            end
            abort()
        end
        add_answer({"bye", "murder", "job", "name"})
        if not get_flag(83) then
            add_dialogue("You see a stern shopkeeper who might once have been a strong fighter.")
            if var_0003 == 7 then
                add_dialogue("\"Thou hast entered my shop, so thou had best buy something.\"")
            end
            add_dialogue("\"Who might I be addressing?\"")
            save_answers()
            var_0006 = ask_answer({var_0002, var_0004})
            if var_0006 == var_0002 then
                add_dialogue("\"Hmph. My name is Dell.\"")
            else
                add_dialogue("\"Oh, art thou really? I did not know there were so many of thee! Why, only last week did an 'Avatar' come through here! He took me for 20 gold, too! An expert trickster, he was!~~Dell looks you up and down. \"Avatar, indeed! I do not like Avatars. But never mind that. I am called Dell. What dost thou want?\"")
            end
            set_flag(83, true)
        else
            add_dialogue("\"How may I help thee?\" Dell asks.")
        end
        while true do
            var_0007 = get_answer()
            if var_0007 == "name" then
                add_dialogue("\"My name is Dell. Did I not say that already?\"")
                remove_answer("name")
            elseif var_0007 == "job" then
                add_dialogue("Dell looks disgruntled. \"I sell weapons, armour, and provisions when I am not doing work for The Fellowship.\"")
                add_answer("buy")
                if var_0003 == 7 then
                    add_dialogue("\"If thou art not going to buy anything, then get thy face out of my sight!\"")
                end
                add_answer("Fellowship")
            elseif var_0007 == "murder" then
                add_dialogue("\"I am afraid I know nothing about it save for what is being said in the street, so do not ask me. If thou art not going to buy anything, then thou art wasting my time. Go away.\"")
                remove_answer("murder")
                var_0008 = npc_id_in_party(1) --- Guess: Checks player status
                if var_0008 then
                    switch_talk_to(1, 0)
                    add_dialogue("Iolo whispers to you, \"Pleasant chap, is he not?\"")
                    hide_npc(1)
                    switch_talk_to(18, 0)
                end
            elseif var_0007 == "Fellowship" then
                unknown_0919H() --- Guess: Explains Fellowship philosophy
                remove_answer("Fellowship")
            elseif var_0007 == "philosophy" then
                unknown_091AH() --- Guess: Provides detailed Fellowship information
                remove_answer("philosophy")
            elseif var_0007 == "buy" then
                if var_0003 == 7 then
                    add_dialogue("\"Certainly, " .. var_0001 .. ". What type of ware wouldst thou wish to see?\"")
                    save_answers()
                    add_answer({"provisions", "armour", "weapons", "nothing"})
                else
                    add_dialogue("\"Come to my shop during business hours.\"")
                end
            elseif var_0007 == "weapons" then
                unknown_0872H() --- Guess: Shows weapons inventory
            elseif var_0007 == "armour" then
                unknown_0873H() --- Guess: Shows armour inventory
            elseif var_0007 == "provisions" then
                unknown_0874H() --- Guess: Shows provisions inventory
            elseif var_0007 == "nothing" then
                restore_answers()
            elseif var_0007 == "bye" then
                break
            end
        end
        add_dialogue("\"Hmpf.\"")
        if var_0003 == 7 then
            add_dialogue("\"Spend more money next time thou dost come in.\"")
        end
    elseif eventid == 0 then
        var_0000 = get_schedule() --- Guess: Checks game state or timer
        var_0003 = unknown_001CH(18) --- Guess: Gets object state
        var_0008 = random(1, 4)
        if var_0003 == 7 then
            if var_0008 == 1 then
                var_0009 = "@Buy something!@"
            elseif var_0008 == 2 then
                var_0009 = "@Armour! Weapons!@"
            elseif var_0008 == 3 then
                var_0009 = "@Swamp boots? Bedrolls?@"
            elseif var_0008 == 4 then
                var_0009 = "@Finest goods here!@"
            end
            bark(18, var_0009)
        else
            unknown_092EH(18) --- Guess: Triggers a game event
        end
    end
end