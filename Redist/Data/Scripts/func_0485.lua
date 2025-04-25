-- Manages Constance's dialogue in New Magincia, covering her job, heartbreak over Henry, and interactions with shipwrecked strangers.
function func_0485(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        switch_talk_to(-133, 0)
        local0 = get_player_name()
        local1 = switch_talk_to(-3)
        local2 = switch_talk_to(-1)
        local3 = switch_talk_to(-4)
        local4 = switch_talk_to(-2)
        local5 = switch_talk_to(-132)

        add_answer({"bye", "job", "name"})
        if not get_flag(384) then
            add_answer("strangers")
        end
        if not get_flag(388) then
            add_answer("scoundrels")
        end
        if not get_flag(461) then
            add_answer("locket found")
        end

        if not get_flag(398) then
            say("You see an angelic young woman who gives you a smile of complete innocence.")
            set_flag(398, true)
        else
            say("\"" .. local0 .. "!\" says a wide-eyed Constance, \"What may I do for thee?\"")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name, " .. local0 .. ", is Constance.\" She shyly lowers her eyes.")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I carry water from the well of humility to all of the homes here in New Magincia.\"")
                add_answer({"New Magincia", "well of humility"})
            elseif answer == "well of humility" then
                say("\"The water from the well is pure and cool. If thou wouldst like I will pour thee some.\"")
                local6 = get_answer()
                if local6 then
                    say("With a big smile Constance takes a dipper and submerges it in the cool water of her bucket. She draws out the dipper and hands it to you. You drink and find the water delicious and very refreshing.")
                    if local2 then
                        switch_talk_to(-1, 0)
                        say("\"Actually, I feel quite parched myself. Might I have some as well?\" Constance nods yes, and hands him a dipper of water. He drinks with loud gulping sounds.*")
                        hide_npc(-1)
                        switch_talk_to(-133, 0)
                    end
                    if local1 then
                        switch_talk_to(-3, 0)
                        say("\"I, too, am feeling dry. Wouldst thou share thy water with me, milady?\" Constance fills the dipper with water for Shamino and he drinks until water runs down his chin.*")
                        hide_npc(-3)
                        switch_talk_to(-133, 0)
                    end
                    if local1 and local3 then
                        switch_talk_to(-3, 0)
                        say("You see Shamino nudge Dupre. \"Art thou not going to have a drink?\"")
                        hide_npc(-3)
                        switch_talk_to(-4, 0)
                        say("\"I shall wait until we find something a bit stronger than water to quench my thirst.\"*")
                        hide_npc(-4)
                        switch_talk_to(-133, 0)
                    end
                    if local4 then
                        switch_talk_to(-2, 0)
                        say("Constance hands Spark a dipper full of water. He drinks it down in one long slurp. Upon finishing it, he burps. With an embarrassed grin he bows apologetically to Constance as he hands her back the dipper.")
                        hide_npc(-2)
                        switch_talk_to(-133, 0)
                    end
                else
                    say("\"If thou wouldst ever change thy mind thou needest only let me know.\"")
                end
                remove_answer("well of humility")
            elseif answer == "strangers" then
                say("\"There are three strangers on the island! They have been shipwrecked here! I have met them. Their leader's name is Robin.\"")
                add_answer("Robin")
                remove_answer("strangers")
                set_flag(384, true)
            elseif answer == "New Magincia" then
                say("\"I was born in New Magincia and I have lived here mine entire life. But now I wish to leave for mine heart hath been broken.\"")
                remove_answer("New Magincia")
                add_answer("heart")
            elseif answer == "heart" then
                if not get_flag(388) then
                    say("\"Once I was in love with Henry, the peddler, but then I learned he is a liar and a cad. Perhaps soon mine heart shall belong to another.\"")
                    add_answer("another")
                else
                    say("You tell Constance of Robin's plans for her. She gives you a shocked look. \"Many thanks. I now know that my rightful place is with Henry.\"")
                end
                remove_answer("heart")
            elseif answer == "locket found" then
                say("You tell Constance of how you have returned the locket that has been stolen from Henry. \"Oh, how could I ever have doubted my dear darling Henry?\" she frowns. \"I thank thee for telling me the truth.\"")
                if local5 then
                    switch_talk_to(-132, 0)
                    say("\"Constance, I am sorry that things ran afoul as they did, but if thou wilt, I would like thee to have this locket as a symbol of my love.\"*")
                    switch_talk_to(-133, 0)
                    say("\"My sweet Henry, mine heart belongs to only thee.\"*")
                    hide_npc(-132)
                    switch_talk_to(-133, 0)
                end
                remove_answer("locket found")
            elseif answer == "another" then
                say("\"There is a charming and mysterious stranger on the island named Robin. He says one day he may show me the world and buy me many fine things.\" Constance sighs. \"He even gave me some lovely flowers.\"")
                remove_answer("another")
                add_answer("Robin")
            elseif answer == "Robin" then
                say("\"He is a wealthy man and his two friends are big, strong men. They have been telling me about a very wonderful-sounding place called Buccaneer's Den.\"")
                remove_answer("Robin")
                add_answer({"Buccaneer's Den", "friends"})
            elseif answer == "friends" then
                say("\"Their names were Battles and Leavell. Both of them treated me like proper gentlemen.\"")
                remove_answer("friends")
                add_answer({"Leavell", "Battles"})
            elseif answer == "Battles" then
                say("\"Battles was quiet at first. I thought he was mean-looking, but he is nice once thou dost get to know him. He told me of the various monsters he fought, and exciting stories of how he raided ships in the south seas.\"")
                remove_answer("Battles")
            elseif answer == "Leavell" then
                say("\"Leavell was charming and witty. He can always make me laugh.\"")
                remove_answer("Leavell")
            elseif answer == "Buccaneer's Den" then
                say("\"Buccaneer's Den must be a wonderland. There is a spinning wheel that gives thee money! Canst thou imagine! And opulent, luxurious baths.\"")
                remove_answer("Buccaneer's Den")
                add_answer({"baths", "spinning wheel"})
            elseif answer == "spinning wheel" then
                say("\"Well, they certainly have nothing like that in New Magincia. I had never even heard of such a thing before!\"")
                remove_answer("spinning wheel")
            elseif answer == "baths" then
                say("\"Doth that not sound nice?\"")
                remove_answer("baths")
            elseif answer == "scoundrels" then
                say("You gently explain to Constance that Robin, Battles and Leavell were scoundrels with intent to do her great harm. She is quite alarmed. Then you explain that they will not be troubling her anymore. She thanks you.")
                remove_answer("scoundrels")
            elseif answer == "bye" then
                say("\"It was a pleasure speaking with thee, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-133)
    end
    return
end