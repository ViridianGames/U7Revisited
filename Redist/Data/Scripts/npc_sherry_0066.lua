--- Best guess: Handles dialogue with Sherry the Mouse, who assists in the Royal Nursery, plays with children, and searches for cheese, offering to recite "Hubert's Hair-Raising Adventure" and accepting cheese from the player.
function npc_sherry_0066(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    start_conversation()
    if eventid == 1 then
        switch_talk_to(66)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        add_answer({"bye", "job", "name"})
        if not get_flag(195) then
            add_dialogue("You see a very large mouse with an air of superior intelligence.")
            add_dialogue("\"Avatar!\" she exclaims. \"I cannot believe thou art here, " .. var_0000 .. "!\"")
            set_flag(195, true)
        else
            add_dialogue("\"Hello, " .. var_0000 .. "!\" Sherry the Mouse exclaims.")
        end
        while true do
            var_0002 = get_answer()
            if var_0002 == "name" then
                add_dialogue("\"Why, dost thou not remember Sherry, " .. var_0000 .. "?\"")
                remove_answer("name")
            elseif var_0002 == "job" then
                var_0002 = get_schedule_type(66) --- Guess: Gets object state
                if var_0002 == 25 then
                    add_dialogue("\"I am trying to keep up with these children! We are playing tag through the castle! I must run! Talk to me later in the nursery!\"")
                    abort()
                else
                    add_dialogue("\"I mainly assist Nanna in the Royal Nursery during the day. I watch the children alone in the evenings while Nanna has dinner and goes to her Fellowship meeting. Other times I run around the castle looking for mouse food!\"")
                    add_answer({"mouse food", "castle", "Royal Nursery"})
                end
            elseif var_0002 == "Royal Nursery" then
                add_dialogue("\"The children are so much fun. I like to read them their favorite story. It happens to be Lord British's favorite children's story, too! He read it to me oh, those many years ago.\"")
                remove_answer("Royal Nursery")
                add_answer({"story", "children"})
            elseif var_0002 == "children" then
                add_dialogue("\"If thou hast not had the chance yet, do look around and meet them. They are most wonderful and amusing.\"")
                remove_answer("children")
            elseif var_0002 == "castle" then
                add_dialogue("\"It is much the same as it was when thou wert last here. There has been a bit of remodeling. After all, it has been 200 years since thou wert last here! I believe Lord British has a storeroom with quite a bit of equipment inside.\"")
                remove_answer("castle")
            elseif var_0002 == "mouse food" then
                add_dialogue("\"Well, cheese is my favorite. If thou dost ever have cheese to give away, I will gladly eat it. But I will generally eat most anything. Dost thou have any cheese for me?\"")
                var_0003 = select_option()
                if var_0003 then
                    var_0004 = utility_unknown_1073(26, 359, 377, 1, 357) --- Guess: Checks for cheese in inventory
                    var_0005 = utility_unknown_1073(27, 359, 377, 1, 357) --- Guess: Checks for cheese in inventory
                    if var_0004 or var_0005 then
                        add_dialogue("\"Want to give me some?\"")
                        var_0006 = select_option()
                        if var_0006 then
                            var_0005 = remove_party_items(true, 26, 359, 377, 1) --- Guess: Deducts cheese
                            var_0006 = remove_party_items(true, 27, 359, 377, 1) --- Guess: Deducts cheese
                            if var_0005 or var_0006 then
                                add_dialogue("\"Thank thee, " .. var_0000 .. "!\"")
                            else
                                add_dialogue("\"I am unable to take thy cheese at the moment, " .. var_0001 .. ".\"")
                            end
                        else
                            add_dialogue("\"Well! I thought thou wert my friend!\"")
                        end
                    else
                        add_dialogue("\"But thou hast not got any cheese!\"")
                    end
                else
                    add_dialogue("\"Too bad! If thou dost find any, please keep me in mind!\"")
                end
                remove_answer("mouse food")
            elseif var_0002 == "story" then
                add_dialogue("\"Dost thou want to hear the story? It is called 'Hubert's Hair-Raising Adventure'.\"")
                var_0007 = select_option()
                if var_0007 then
                    add_dialogue("Sherry stands on her hind legs, takes a deep breath, and then recites -- from memory -- very, very fast:")
                    save_answers()
                    utility_unknown_1004() --- Guess: Recites "Hubert's Hair-Raising Adventure"
                else
                    add_dialogue("\"Some other time, then!\"")
                end
                remove_answer("story")
            elseif var_0002 == "bye" then
                break
            end
        end
        add_dialogue("\"Farewell, " .. var_0001 .. "!\"")
    elseif eventid == 0 then
        var_0002 = get_schedule_type(66) --- Guess: Gets object state
        if var_0002 == 25 then
            var_0007 = random(1, 4)
            if var_0007 == 1 then
                var_0008 = "@Tag! Thou art it!@"
            elseif var_0007 == 2 then
                var_0008 = "@Cannot catch me!@"
            elseif var_0007 == 3 then
                var_0008 = "@Nyah nyah! Thou art it!@"
            elseif var_0007 == 4 then
                var_0008 = "@Catch me if thou can!@"
            end
            bark(66, var_0008)
        end
    end
end