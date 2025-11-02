--- Best guess: Handles dialogue with Constance, the waterbearer of New Magincia, discussing her job, heartbreak over Henry, and her interactions with three strangers (Robin, Battles, Leavell) who mislead her about Buccaneer's Den.
function npc_constance_0133(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    start_conversation()
    if eventid == 1 then
        switch_talk_to(133)
        var_0000 = get_lord_or_lady()
        var_0001 = npc_id_in_party(3) --- Guess: Checks player status
        var_0002 = npc_id_in_party(1) --- Guess: Checks player status
        var_0003 = npc_id_in_party(4) --- Guess: Checks player status
        var_0004 = npc_id_in_party(2) --- Guess: Checks player status
        var_0005 = npc_id_in_party(132) --- Guess: Checks player status
        add_answer({"bye", "job", "name"})
        if not get_flag(384) then
            add_answer("strangers")
        end
        if not get_flag(388) then
            add_answer("scoundrels")
        end
        if get_flag(461) then
            add_answer("locket found")
        end
        if not get_flag(398) then
            add_dialogue("You see an angelic young woman who gives you a smile of complete innocence.")
            set_flag(398, true)
        else
            add_dialogue("\"" .. var_0000 .. "!\" says a wide-eyed Constance, \"What may I do for thee?\"")
        end
        while true do
            var_0006 = get_answer()
            if var_0006 == "name" then
                add_dialogue("\"My name, " .. var_0000 .. ", is Constance.\" She shyly lowers her eyes.")
                remove_answer("name")
            elseif var_0006 == "job" then
                add_dialogue("\"I carry water from the well of humility to all of the homes here in New Magincia.\"")
                add_answer({"New Magincia", "well of humility"})
            elseif var_0006 == "well of humility" then
                add_dialogue("\"The water from the well is pure and cool. If thou wouldst like I will pour thee some.\"")
                var_0006 = select_option()
                if var_0006 then
                    add_dialogue("With a big smile Constance takes a dipper and submerges it in the cool water of her bucket. She draws out the dipper and hands it to you. You drink and find the water delicious and very refreshing.")
                    if var_0002 then
                        switch_talk_to(1)
                        add_dialogue("\"Actually, I feel quite parched myself. Might I have some as well?\" Constance nods yes, and hands him a dipper of water. He drinks with loud gulping sounds.")
                        hide_npc(1)
                        switch_talk_to(133)
                    end
                    if var_0001 then
                        switch_talk_to(3)
                        add_dialogue("\"I, too, am feeling dry. Wouldst thou share thy water with me, milady?\" Constance fills the dipper with water for Shamino and he drinks until water runs down his chin.")
                        hide_npc(3)
                        switch_talk_to(133)
                    end
                    if var_0003 and not var_0001 then
                        switch_talk_to(3)
                        add_dialogue("You see Shamino nudge Dupre. \"Art thou not going to have a drink?\"")
                        hide_npc(3)
                        switch_talk_to(4)
                        add_dialogue("\"I shall wait until we find something a bit stronger than water to quench my thirst.\"")
                        hide_npc(4)
                        switch_talk_to(133)
                    end
                    if var_0004 then
                        switch_talk_to(2)
                        add_dialogue("Constance hands Spark a dipper full of water. He drinks it down in one long slurp. Upon finishing it, he burps. With an embarrassed grin he bows apologetically to Constance as he hands her back the dipper.")
                        hide_npc(2)
                        switch_talk_to(133)
                    end
                else
                    add_dialogue("\"If thou wouldst ever change thy mind thou needest only let me know.\"")
                end
                remove_answer("well of humility")
            elseif var_0006 == "strangers" then
                add_dialogue("\"There are three strangers on the island! They have been shipwrecked here! I have met them. Their leader's name is Robin.\"")
                add_answer("Robin")
                remove_answer("strangers")
                set_flag(384, true)
            elseif var_0006 == "New Magincia" then
                add_dialogue("\"I was born in New Magincia and I have lived here mine entire life. But now I wish to leave for mine heart hath been broken.\"")
                remove_answer("New Magincia")
                add_answer("heart")
            elseif var_0006 == "heart" then
                if not get_flag(388) then
                    add_dialogue("\"Once I was in love with Henry, the peddler, but then I learned he is a liar and a cad. Perhaps soon mine heart shall belong to another.\"")
                    add_answer("another")
                else
                    add_dialogue("You tell Constance of Robin's plans for her. She gives you a shocked look. \"Many thanks. I now know that my rightful place is with Henry.\"")
                end
                remove_answer("heart")
            elseif var_0006 == "locket found" then
                add_dialogue("You tell Constance of how you have returned the locket that has been stolen from Henry. \"Oh, how could I ever have doubted my dear darling Henry?\" she frowns. \"I thank thee for telling me the truth.\"")
                if var_0005 then
                    switch_talk_to(132)
                    add_dialogue("\"Constance, I am sorry that things ran afoul as they did, but if thou wilt, I would like thee to have this locket as a symbol of my love.\"")
                    switch_talk_to(133)
                    add_dialogue("\"My sweet Henry, mine heart belongs to only thee.\"")
                    hide_npc(132)
                    switch_talk_to(133)
                end
                remove_answer("locket found")
            elseif var_0006 == "another" then
                add_dialogue("\"There is a charming and mysterious stranger on the island named Robin. He says one day he may show me the world and buy me many fine things.\" Constance sighs. \"He even gave me some lovely flowers.\"")
                remove_answer("another")
                add_answer("Robin")
            elseif var_0006 == "Robin" then
                add_dialogue("\"He is a wealthy man and his two friends are big, strong men. They have been telling me about a very wonderful-sounding place called Buccaneer's Den.\"")
                remove_answer("Robin")
                add_answer({"Buccaneer's Den", "friends"})
            elseif var_0006 == "friends" then
                add_dialogue("\"Their names were Battles and Leavell. Both of them treated me like proper gentlemen.\"")
                remove_answer("friends")
                add_answer({"Leavell", "Battles"})
            elseif var_0006 == "Buccaneer's Den" then
                add_dialogue("\"Buccaneer's Den must be a wonderland. There is a spinning wheel that gives thee money! Canst thou imagine! And opulent, luxurious baths.\"")
                remove_answer("Buccaneer's Den")
                add_answer({"baths", "spinning wheel"})
            elseif var_0006 == "Battles" then
                add_dialogue("\"Battles was quiet at first. I thought he was mean-looking, but he is nice once thou dost get to know him. He told me of the various monsters he fought, and exciting stories of how he raided ships in the south seas.\"")
                remove_answer("Battles")
            elseif var_0006 == "Leavell" then
                add_dialogue("\"Leavell was charming and witty. He can always make me laugh.\"")
                remove_answer("Leavell")
            elseif var_0006 == "spinning wheel" then
                add_dialogue("\"Well, they certainly have nothing like that in New Magincia. I had never even heard of such a thing before!\"")
                remove_answer("spinning wheel")
            elseif var_0006 == "baths" then
                add_dialogue("\"Doth that not sound nice?\"")
                remove_answer("baths")
            elseif var_0006 == "scoundrels" then
                add_dialogue("You gently explain to Constance that Robin, Battles and Leavell were scoundrels with intent to do her great harm. She is quite alarmed. Then you explain that they will not be troubling her anymore. She thanks you.")
                remove_answer("scoundrels")
            elseif var_0006 == "bye" then
                break
            end
        end
        add_dialogue("\"It was a pleasure speaking with thee, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        utility_unknown_1070(133) --- Guess: Triggers a game event
    end
end