--- Best guess: Manages Budo’s dialogue in Buccaneer’s Den, a cheerful merchant selling provisions, weapons, armor, and a ship deed, with ties to The Fellowship.
function func_04E5(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    if eventid == 1 then
        switch_talk_to(0, 229)
        var_0000 = get_schedule()
        var_0001 = unknown_001CH(get_npc_name(229))
        var_0002 = unknown_0931H(1, 359, 981, 1, 357)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(309) or get_flag(260) then
            add_answer("Crown Jewel")
        end
        if not get_flag(690) then
            add_dialogue("You see a fat, cheerful-looking merchant.")
            if var_0001 == 7 then
                add_dialogue("\"Hello, hello my friend! Thou dost look like thou needest to spend money!\"")
                var_0003 = npc_id_in_party(3)
                if var_0003 then
                    switch_talk_to(0, 3)
                    add_dialogue("\"This place looks quite well-off.\"")
                    hide_npc(3)
                    var_0004 = npc_id_in_party(1)
                    if var_0004 then
                        switch_talk_to(0, 1)
                        add_dialogue("\"The entire island is very opulent. It is not the same island we once knew.\"")
                        hide_npc(1)
                    end
                    switch_talk_to(0, 229)
                end
            else
                add_dialogue("\"Hello! How art thou, my friend?\"")
            end
            set_flag(690, true)
        else
            add_dialogue("\"How may I help thee?\" Budo asks.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Budo the Fourth at thy service! 'Tis a fine day today, is it not?\"")
                remove_answer("name")
            elseif answer == "job" then
                if var_0001 == 7 then
                    var_0005 = "thou hast come to the right place!"
                    var_0006 = ""
                    var_0007 = ""
                    add_answer({"ship deed", "provisions", "armour", "weapons"})
                else
                    var_0005 = "thou shouldst come to my shoppe when"
                    var_0006 = "it is open! I would be so pleased to"
                    var_0007 = "help thee then."
                end
                add_dialogue("\"I am a provisioner, like my father before me, and like his father before him, and like his father before him. Budo's is an island tradition! Just as The Fellowship will be someday!\"")
                add_dialogue("\"If thou art interested in weapons, armour, provisions, or a ship deed, " .. var_0005 .. var_0006 .. var_0007 .. "")
                add_answer("Fellowship")
            elseif answer == "armour" then
                add_dialogue("\"Budo's carries nothing but the finest quality armour in all Britannia. I have all the best types of equipment available.\"")
                unknown_0859H()
            elseif answer == "weapons" then
                add_dialogue("\"Budo's offers thee excellent weaponry with superb craftsmanship. Thou wilt not find a better buy for thy money anywhere else!\"")
                unknown_0858H()
            elseif answer == "provisions" then
                add_dialogue("\"Budo's also carries a variety of useful things for thy convenience.\"")
                unknown_085AH()
            elseif answer == "ship deed" then
                if get_flag(694) then
                    add_dialogue("\"But I have already sold thee the deed to 'The Lusty Wench'! She was the only ship I had at this particular time! I am sorry!\"")
                else
                    add_dialogue("\"I can sell thee the deed to my ship 'The Lusty Wench.' She is beautiful, my friend. She is guaranteed to last and is the sleekest vessel on the seas! She goes for 800 gold. Want her?\"")
                    if ask_yes_no() then
                        var_0008 = get_party_gold()
                        if var_0008 >= 800 then
                            var_0009 = unknown_002CH(false, 2, 18, 797, 1)
                            if not var_0009 then
                                add_dialogue("\"A wise move. A magnificent ship for thee!\" He takes your gold.")
                                var_000A = unknown_002BH(true, 359, 359, 644, 800)
                                set_flag(694, true)
                            else
                                add_dialogue("\"Thou art carrying too much, my friend! Unload thyself of some of thy belongings and I will sell thee the deed to this beautiful ship.\"")
                            end
                        else
                            add_dialogue("\"But thou dost not have enough gold! Perhaps thou shouldst visit the House of Games and increase the bulges in thy pockets!\"")
                        end
                    else
                        add_dialogue("\"But thou wilt never see a ship like this one anywhere in the world! Too bad!\"")
                    end
                end
                remove_answer("ship deed")
            elseif answer == "Fellowship" then
                add_dialogue("\"The Fellowship has helped me to become a very rich man! Although the business is an inherited enterprise, I owe everything to The Fellowship!\"")
                remove_answer("Fellowship")
                add_answer({"everything", "inherited", "rich man"})
            elseif answer == "rich man" then
                add_dialogue("\"My great-grandfather started this business many, many years ago. He was moderately successful, thanks to the Thieves' Guild. But that era has passed.\"")
                add_answer("Thieves' Guild")
                remove_answer("rich man")
            elseif answer == "inherited" then
                add_dialogue("\"My great-grandfather passed the shoppe on to his son, and so forth, down to me. We are born merchants! That is why I know why thou hast come to Budo's! Thou wantest to become a part of the great Budo Legacy! Thou dost need to buy something!\"")
                remove_answer("inherited")
            elseif answer == "everything" then
                add_dialogue("\"There was a period shortly after my father died, just as I had inherited the shoppe, when business was poor. There was a danger that I would not be able to keep the shoppe open. But The Fellowship convinced me that I should join them. I proved my worthiness and The Fellowship helped me financially.\"")
                remove_answer("everything")
                add_answer("worthiness")
            elseif answer == "worthiness" then
                add_dialogue("\"I do not mind telling thee. The Fellowship shares in one half of my profit.\"")
                remove_answer("worthiness")
            elseif answer == "Thieves' Guild" then
                add_dialogue("\"It is no more. They dwindled away during my grandfather's time. By the time The Fellowship arrived, when I was a boy, there was no trace of them except in family mementos. Even the pirates are different.\"")
                remove_answer("Thieves' Guild")
            elseif answer == "Crown Jewel" then
                if var_0002 then
                    add_dialogue("The cube vibrates a moment.")
                    add_dialogue("\"That ship sails here frequently. I know it makes regular runs to the mainland, stops here, then moves on to the Isle of the Avatar the next morning. Then it repeats the trip, going the other direction.\"")
                else
                    add_dialogue("\"It stops here regularly. Don't know much more about it. The crew is very secretive.\" Budo looks away, obviously not wanting to talk about the ship.")
                end
                remove_answer("Crown Jewel")
            elseif answer == "bye" then
                add_dialogue("\"I hope I can help thee again some time, my friend!\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0000 = get_schedule()
        var_0001 = unknown_001CH(get_npc_name(229))
        if var_0001 == 7 then
            var_000B = random2(4, 1)
            if var_000B == 1 then
                var_000C = "@Weapons? Armour?@"
            elseif var_000B == 2 then
                var_000C = "@Provisions here!@"
            elseif var_000B == 3 then
                var_000C = "@Budo's is open for business!@"
            elseif var_000B == 4 then
                var_000C = "@Step right in! We're open!@"
            end
            bark(var_000C, 229)
        else
            unknown_092EH(229)
        end
    end
    return
end