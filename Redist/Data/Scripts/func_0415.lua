--- Best guess: Handles dialogue with Gargan, the Trinsic shipwright, discussing ship and sextant purchases, the local murder, and sightings of Hook and the Crown Jewel.
function func_0415(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    start_conversation()
    if eventid == 1 then
        switch_talk_to(21, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = 0 --unknown_001CH(21) --- Guess: Gets object state
        var_0002 = 0

        if not get_flag(85) then
            add_dialogue("You see a salty old sailor who reeks of tobacco.")
            set_flag(85, true)
        else
            add_dialogue("\"Yes, matey?\" Gargan asks, coughing.")
        end

        add_answer({"bye", "murder", "job", "name"})
        if get_flag(64) then
            add_answer("Crown Jewel")
        end
        if not get_flag(63) then
            add_answer("Fellowship")
        end
        if not get_flag(67) then
            add_answer("Hook")
        end

        while true do
            coroutine.yield()
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"My name is Gargan.\"")
                add_dialogue("He sniffs loudly.")
                remove_answer("name")
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "job" then
                add_dialogue("\"I am the Trinsic shipwright. If thou wouldst like to know about a ship or a sextant, just say so.\"")
                add_dialogue("Gargan coughs.")
                add_answer({"sextant", "ship"})
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "ship" then
                add_dialogue("\"Thou dost want to buy a ship?\" the old man asks, smiling. (Apparently not too many folks buy ships these days.)")
                add_dialogue("My ships are sturdy and well built. They may not be built by Owen, but they are fine vessels! But thou must first purchase a deed.")
                add_dialogue("Gargan wipes his runny nose on his sleeve.")
                remove_answer("ship")
                add_answer({"deed", "Owen"})
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "sextant" then
                if var_0001 ~= 30 then
                    add_dialogue("\"Well, ye'll have to come to the shop when it is open.\"")
                else
                    add_dialogue("\"I sell sextants for 80 gold. Want one?\"")
                    add_dialogue("Gargan clears his throat.")
                    var_0004 = select_option()
                    if var_0004 then
                        var_0003 = unknown_0028H(359, 359, 644, 357) --- Guess: Checks gold amount
                        if var_0003 >= 80 then
                            add_dialogue("\"Here ye are!\"")
                            var_0004 = unknown_002CH(true, 359, 650, 1) --- Guess: Adds item to inventory
                            if not var_0004 then
                                add_dialogue("\"Thine arms are too full to carry the sextant!\"")
                                add_dialogue("Gargan sneezes.")
                            end
                        else
                            add_dialogue("\"Thou dost not have enough gold, sailor.\"")
                            add_dialogue("Gargan sneezes.")
                        end
                    else
                        add_dialogue("\"Suit thyself.\"")
                        add_dialogue("Gargan sneezes.")
                    end
                end
                remove_answer("sextant")
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "Owen" then
                add_dialogue("\"Thou hast not heard of Owen? Finest shipwright in the land. He lives in Minoc.\"")
                add_dialogue("Gargan coughs.")
                remove_answer("Owen")
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "deed" then
                if var_0001 ~= 30 then
                    add_dialogue("\"Well, ye'll have to come to the shop when it is open.\"")
                else
                    if get_flag(88) then
                        add_dialogue("\"I already sold thee the deed to 'The Scaly Eel'! It was the only ship I had!\"")
                        add_dialogue("Gargan coughs loudly.")
                    else
                        add_dialogue("\"The deed I can sell thee is for the ship 'The Scaly Eel.' It goes for 600 gold. Interested?\"")
                        var_0005 = select_option()
                        if var_0005 then
                            var_0003 = unknown_0028H(359, 359, 644, 357) --- Guess: Checks gold amount
                            if var_0003 >= 600 then
                                var_0006 = unknown_002CH(true, 359, 797, 1) --- Guess: Adds item to inventory
                                if var_0006 then
                                    add_dialogue("\"All right, then!\" the sailor replies. He hands you the deed and takes your gold.")
                                    add_dialogue("Gargan sneezes.")
                                    var_0007 = unknown_002BH(359, 359, 644, 600) --- Guess: Removes gold
                                    set_flag(88, true)
                                else
                                    add_dialogue("\"Thou'rt already carrying enough to sink a galleon, " .. var_0000 .. "! If thou wilt leave something behind, mayhaps thou wilt be able to sail, and I will be glad, indeed, to sell thee the deed.\"")
                                    add_dialogue("Gargan sneezes.")
                                end
                            else
                                add_dialogue("\"Sorry, matey,\" Gargan says. \"Thou dost not have enough gold!\"")
                                add_dialogue("Gargan sneezes.")
                            end
                        else
                            add_dialogue("\"Some other time, then,\" the sailor shrugs, disappointed.")
                            add_dialogue("Gargan sneezes.")
                        end
                    end
                end
                remove_answer("deed")
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "murder" then
                add_dialogue("\"I heard about that. Terrible thing to happen. Can't say I saw or heard anything, though.\"")
                add_dialogue("Gargan coughs, clears his throat loudly, then spits.")
                var_0008 = npc_id_in_party(2) --- Guess: Checks player status
                if var_0008 then
                    switch_talk_to(2, 0)
                    add_dialogue("\"Ooooh, yuck!\"")
                    hide_npc(2)
                    switch_talk_to(21, 0)
                end
                remove_answer("murder")
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "Crown Jewel" then
                add_dialogue("\"Yes, that ship was docked overnight.\" He consults his log. \"She sailed for Britain at sunrise. I do not recall seeing anyone get on or off.\"")
                add_dialogue("Gargan snorts and coughs a couple of times.")
                remove_answer("Crown Jewel")
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "Hook" then
                add_dialogue("\"Matey, I have always seen pirates and sailors with peglegs and hooks. If thou hast seen one, thou hast seen another.\" But the man suddenly frowns. \"Hmm. Now that thou dost mention it, I -did- see a man with a hook late last night after sundown. I was leaving the shop and saw him outside. There was a wingless gargoyle with him. They were walking east.\"")
                add_dialogue("Gargan sneezes, then coughs a couple of times.")
                var_0008 = npc_id_in_party(2)
                if var_0008 then
                    switch_talk_to(2, 0)
                    add_dialogue("\"I told thee! It was him!\"")
                    --hide_npc(2)
                    switch_talk_to(21, 0)
                end
                remove_answer("Hook")
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "Fellowship" then
                add_dialogue("\"I am too old to pay attention to them.\"")
                add_dialogue("Gargan wipes his runny nose on his sleeve.")
                remove_answer("Fellowship")
                var_0002 = var_0002 + 1
                if var_0002 == 6 then
                    unknown_088DH() --- Guess: Checks shop hours
                end
            elseif var_0003 == "bye" then
                add_dialogue("\"May thy day have smooth sailing,\" the sailor starts to say, but a coughing spasm interrupts him.")
                clear_answers()        
            end
        end
    elseif eventid == 0 then
        unknown_092EH(21) --- Guess: Triggers a game event
    end
end