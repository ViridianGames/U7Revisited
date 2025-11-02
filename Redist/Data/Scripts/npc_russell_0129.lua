--- Best guess: Handles dialogue with Russell, a shipwright in New Magincia, selling ship deeds and sextants, and discussing a shipwreck involving three strangers, a locket, the Crown Jewel, and Hook.
function npc_russell_0129(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    if eventid == 1 then
        switch_talk_to(129)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule(129) --- Guess: Checks game state
        var_0002 = get_schedule_type(129) --- Guess: Gets object state
        var_0003 = is_player_wearing_fellowship_medallion() --- Guess: Checks Fellowship membership
        add_answer({"bye", "job", "name"})
        if not get_flag(381) then
            add_answer("locket")
        end
        if var_0003 then
            add_answer("medallion")
        end
        if not get_flag(295) then
            add_answer({"Crown Jewel", "Hook"})
        end
        if not get_flag(384) then
            add_answer("strangers")
        end
        if not get_flag(394) then
            add_dialogue("Before you is a shrewd-looking craftsman, obviously filled with the contentment of a peaceful life.")
            set_flag(394, true)
        else
            add_dialogue("\"What may I do for thee?\" says Russell.")
        end
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("\"I am Russell, a shipwright.\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                add_dialogue("\"I build ships in New Magincia. It is a profession I enjoy very much. I also sell deeds for my ships, and sextants by which one can navigate the open seas.\"")
                add_answer({"sextants", "deeds", "New Magincia"})
            elseif var_0004 == "deeds" then
                if var_0002 == 7 then
                    if get_flag(403) then
                        add_dialogue("\"But I have already sold thee the deed to 'The Nymphet'! I am afraid that was the only ship I had at this time.\"")
                    else
                        add_dialogue("\"Thou wishest to purchase my ship 'The Nymphet'? The deed will cost thee 600 gold.\"")
                        var_0005 = select_option()
                        if var_0005 then
                            var_0006 = get_party_gold() --- Guess: Counts items
                            if var_0006 >= 600 then
                                var_0007 = add_party_items(false, 359, 17, 797, 1) --- Guess: Checks inventory space
                                if var_0007 then
                                    add_dialogue("\"'The Nymphet' is thine, " .. var_0000 .. ". Enjoy the waters.\"")
                                    var_0008 = remove_party_items(true, 359, 359, 644, 600) --- Guess: Deducts item and adds item
                                    set_flag(403, true)
                                else
                                    add_dialogue("\"Thou art carrying too much to take thy deed. Come back after putting some things down.\"")
                                end
                            else
                                add_dialogue("\"Mine apologies, " .. var_0000 .. ", thou dost not have enough gold.\"")
                            end
                        else
                            add_dialogue("\"I understand, " .. var_0000 .. ", the seas aren't for everyone.\"")
                        end
                    end
                else
                    add_dialogue("\"When my shop is again open I shall be more than happy to help thee.\"")
                end
                remove_answer("deeds")
            elseif var_0004 == "sextants" then
                if var_0002 == 7 then
                    add_dialogue("\"Thou wishest to purchase one of my fine sextants? 'Twill cost thee 40 gold.\"")
                    var_0009 = select_option()
                    if var_0009 then
                        var_000A = utility_unknown_1073(359, 359, 644, 40, 357) --- Guess: Checks item in inventory
                        if var_000A then
                            add_dialogue("\"'Tis thine, " .. var_0000 .. ". Enjoy the waters.\"")
                            var_000B = remove_party_items(true, 359, 359, 644, 40) --- Guess: Deducts item and adds item
                            var_000B = add_party_items(true, 359, 359, 650, 1) --- Guess: Checks inventory space
                            if not var_000B then
                                add_dialogue("\"I would gladly give thee thy sextant but thou shalt have to put something down! Thou art carrying too much to take it.\"")
                            end
                        else
                            add_dialogue("\"Mine apologies, " .. var_0000 .. ", thou dost not have enough gold.\"")
                        end
                    else
                        add_dialogue("\"I understand, " .. var_0000 .. ", some of us can navigate with just the naked stars!\"")
                    end
                else
                    add_dialogue("\"At present my shop is closed. If thou wilt come back during business hours I shall be more than happy to help thee.\"")
                end
                remove_answer("sextants")
            elseif var_0004 == "New Magincia" then
                add_dialogue("\"Things have been very peaceful in New Magincia. There has been little trouble from outsiders lately.\"")
                add_answer("outsiders")
                remove_answer("New Magincia")
            elseif var_0004 == "outsiders" then
                add_dialogue("\"Before thine arrival there had not been a stranger in New Magincia for years, save for the survivors of the shipwreck.\"")
                add_answer("shipwreck")
                remove_answer("outsiders")
            elseif var_0004 == "shipwreck" then
                add_dialogue("\"I found the wreckage. Three men were clinging to it for their lives.\"")
                add_answer({"three men", "wreckage"})
                remove_answer("shipwreck")
            elseif var_0004 == "wreckage" then
                add_dialogue("\"I had never seen a ship like it before. The markings show it was constructed by a Minoc shipwright named Owen. It was not very well constructed.\"")
                remove_answer("wreckage")
            elseif var_0004 == "three men" or var_0004 == "strangers" then
                add_dialogue("\"They were from Buccaneer's Den. Most people that come here come because they are lost on their way to or from Buccaneer's Den.\"")
                set_flag(384, true)
                add_answer("Buccaneer's Den")
                remove_answer({"three men", "strangers"})
            elseif var_0004 == "Buccaneer's Den" then
                add_dialogue("\"The three men wish to go back. They say there is a house of games in Buccaneer's Den.\" Russell shrugs. \"As if that would be a reason to go there.\"")
                add_dialogue("\"I offered to sell them a ship, but they had no money. They actually seemed offended when I would not give it to them for free!\"")
                remove_answer("Buccaneer's Den")
            elseif var_0004 == "locket" then
                add_dialogue("\"The three strangers tried to offer me some kind of trinket to build or sell them a ship. It sounds like the locket thou art describing.\"")
                add_answer("trinket")
                remove_answer("locket")
            elseif var_0004 == "trinket" then
                add_dialogue("\"I would not have accepted their offer, but I was curious. Later they said nothing when I wanted to see the trinket again. I doubt they have it.\"")
                remove_answer("trinket")
            elseif var_0004 == "medallion" then
                add_dialogue("\"I could not help noticing your medallion. It does look somewhat sinister. I cannot recall ever having seen one like it before.\"")
                remove_answer("medallion")
            elseif var_0004 == "Crown Jewel" then
                if not get_flag(385) then
                    add_dialogue("\"The Crown Jewel just left here a short while ago. I do not know where it was headed.\"")
                    set_flag(385, true)
                else
                    add_dialogue("\"I have heard nothing more of the Crown Jewel since we last spoke of it.\"")
                end
                remove_answer("Crown Jewel")
            elseif var_0004 == "Hook" then
                if not get_flag(386) then
                    add_dialogue("\"Just as the Crown Jewel left I saw a man with a hook jump on board. There was a gargoyle accompanying him.\"")
                    set_flag(386, true)
                else
                    add_dialogue("\"I have heard nothing more of this man Hook since we last spoke of him.\"")
                end
                remove_answer("Hook")
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("\"Fare thee well, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        utility_unknown_1070(129) --- Guess: Triggers a game event
    end
end