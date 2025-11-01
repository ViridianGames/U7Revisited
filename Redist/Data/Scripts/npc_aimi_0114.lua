--- Best guess: Handles dialogue with Aimi, a monk at Yew's Abbey, discussing her gardening, painting, and winemaking, offering flower bouquets for sale or as a gift for Reyna's loss, and directing the player to Taylor for local knowledge.
function npc_aimi_0114(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    start_conversation()
    if eventid == 1 then
        switch_talk_to(114, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = false
        add_answer({"bye", "job", "name"})
        if get_flag(346) and get_flag(347) then
            add_answer("garden")
        end
        if not get_flag(332) then
            add_dialogue("The monk pulls back her cowl far enough for you to see her face.")
            set_flag(332, true)
        else
            add_dialogue("\"Greetings, " .. var_0000 .. ". I hope thy days are full of beauty.\"")
        end
        while true do
            var_0002 = get_answer()
            if var_0002 == "name" then
                add_dialogue("\"Thou mayest call me Aimi, " .. var_0000 .. ".\"")
                set_flag(347, true)
                if not get_flag(346) and not var_0001 then
                    add_answer("garden")
                end
                remove_answer("name")
            elseif var_0002 == "job" then
                add_dialogue("\"As a monk, I am not sure how to answer thy question. I often help to make wine. However, " .. var_0000 .. ", in my spare time I paint or tend my garden here at the Abbey.\"")
                add_answer({"Abbey", "garden", "paint"})
                if not get_flag(328) then
                    add_answer("Kreg")
                end
            elseif var_0002 == "Abbey" then
                add_dialogue("\"I have spent little time with others in the area. Thou mayest wish to speak with Taylor, for he knows much more about the people, animals, and sights in this area than I do.\"")
                add_answer("Taylor")
                remove_answer("Abbey")
            elseif var_0002 == "Taylor" then
                add_dialogue("\"He is a fellow monk. He spends his time studying the plants, animals, and geography of Britannia.\"")
                remove_answer("Taylor")
            elseif var_0002 == "paint" then
                add_dialogue("\"Yes,\" she blushes, \"I have long admired those who are able to express themselves visually. Sadly,\" she says, laughing, \"I am not very good. However, I also collect art. In fact, I have an original Sterling hanging in my room. Perhaps thou couldst see it sometime.\"")
                remove_answer("paint")
            elseif var_0002 == "garden" then
                var_0001 = true
                add_dialogue("\"My garden? I have been tending it for years now. I am a firm believer in the value of aesthetics, so I plant only flowers. Sometimes I sell them in bouquets when people want them, but I do that very rarely.\"")
                add_answer({"buy", "aesthetics"})
                remove_answer("garden")
            elseif var_0002 == "aesthetics" then
                add_dialogue("\"It refers to the practice or study of all things beautiful.\"")
                remove_answer("aesthetics")
            elseif var_0002 == "buy" then
                add_dialogue("\"Thou wishest to buy a bouquet?\"")
                var_0002 = select_option()
                if var_0002 then
                    add_dialogue("\"Dost thou have anyone to give these flowers to?\"")
                    var_0003 = select_option()
                    if var_0003 then
                        if get_flag(296) and not get_flag(348) then
                            add_dialogue("You tell her about the passing away of Reyna's mother.")
                            add_dialogue("\"Ah, yes. I had heard of Reyna's loss. That is a noble reason. Please take these flowers and give them to her.\"")
                            var_0004 = add_party_items(true, 4, 359, 999, 1) --- Guess: Checks inventory space
                            set_flag(348, true)
                        else
                            add_dialogue("\"Good. 'Tis always best to have someone to receive flowers. The flowers will cost 10 gold. Dost thou still want them?\"")
                            var_0003 = select_option()
                            if var_0003 then
                                var_0006 = utility_unknown_1073(359, 359, 644, 10, 357) --- Guess: Checks item in inventory
                                var_0007 = add_party_items(true, 4, 359, 999, 1) --- Guess: Checks inventory space
                                if var_0006 then
                                    if var_0007 then
                                        var_0008 = remove_party_items(true, 359, 359, 644, 10) --- Guess: Deducts item and adds item
                                        add_dialogue("\"I think thou wilt find these to be exceptionally beautiful.\"")
                                    else
                                        add_dialogue("\"It appears thou dost not have room for my flowers. A pity.\"")
                                    end
                                else
                                    add_dialogue("\"I am sorry, " .. var_0000 .. ". Thou dost not have the gold.\"")
                                end
                            else
                                add_dialogue("\"I understand, " .. var_0000 .. ". Free flowers are indeed the best. And wild flowers are quite free. For now, " .. var_0000 .. ", do no more than promise me thou wilt take the time to enjoy my garden.\"")
                            end
                        end
                    else
                        add_dialogue("\"That is indeed unfortunate, " .. var_0000 .. ". 'Tis always best to have someone to receive flowers.\"")
                    end
                else
                    add_dialogue("\"Perhaps next time, thou mightest be interested. For now, " .. var_0000 .. ", do no more than promise me thou wilt take the time to enjoy my garden.\"")
                end
                remove_answer("buy")
            elseif var_0002 == "Kreg" then
                add_dialogue("\"I am afraid I do not know of such a person.\"")
                remove_answer("Kreg")
            elseif var_0002 == "bye" then
                break
            end
        end
        add_dialogue("\"Fare thee well, " .. var_0000 .. ". May the sweet scent of beauty never pass thee by.\"")
        abort()
    elseif eventid == 0 then
        utility_unknown_1070(114) --- Guess: Triggers a game event
    end
end