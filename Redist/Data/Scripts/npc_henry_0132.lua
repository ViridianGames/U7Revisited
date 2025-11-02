--- Best guess: Handles dialogue with Henry, a heartbroken peddler in New Magincia, discussing his lost locket meant for Constance, his childhood friend Katrina, and three strangers who may have taken it.
function npc_henry_0132(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        switch_talk_to(132)
        var_0000 = get_lord_or_lady()
        add_answer({"bye", "job", "name"})
        if not get_flag(384) then
            add_answer("strangers")
        end
        if not get_flag(383) and not get_flag(461) then
            add_answer("found")
        end
        if not get_flag(397) then
            add_dialogue("You see a scruffy young man who is obviously suffering from a broken heart.")
            set_flag(397, true)
        else
            add_dialogue("Henry greets you. \"It is good to speak with thee again, " .. var_0000 .. "!\"")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"My name is Henry, " .. var_0000 .. ".\"")
                remove_answer("name")
            elseif var_0001 == "job" then
                if not get_flag(381) or get_flag(461) then
                    add_dialogue("\"Job?! Who can work when he has a broken heart?!\"")
                    add_answer("broken heart")
                else
                    add_dialogue("\"Although I am called a peddler, I have the greatest selection of items to be found in New Magincia.\"")
                    add_answer("New Magincia")
                end
            elseif var_0001 == "New Magincia" then
                add_dialogue("\"I have lived here all of my life and have never known anyplace else. It is a basically a very nice place where people still adhere to the old ways and values. The rest of the world must think it has passed us by, but it is they who have lost what once was.\"")
                remove_answer("New Magincia")
            elseif var_0001 == "broken heart" then
                add_dialogue("\"I have been rejected by the woman I love.\"")
                add_answer("woman")
                remove_answer("broken heart")
            elseif var_0001 == "woman" then
                add_dialogue("His eyes light up. \"Her name is Constance, she is the most beautiful woman in the world, and for a time we were in love.\" His face falls, and he sighs deeply. \"But that was before I made a terrible mistake...\"")
                add_answer({"mistake", "Constance"})
                remove_answer("woman")
            elseif var_0001 == "Constance" then
                add_dialogue("\"She is the waterbearer of the town. She carries water from the well of Humility to all the homes in town.\"")
                remove_answer("Constance")
            elseif var_0001 == "mistake" then
                add_dialogue("\"I promised to give her a very old and valuable locket as a token of mine affection. My childhood friend, Katrina, had given the locket to me.\"")
                remove_answer("mistake")
                add_answer({"Katrina", "locket"})
            elseif var_0001 == "locket" then
                add_dialogue("\"Before I could give her the locket, I lost it. I have searched everywhere but I cannot find it. Now, Constance thinks I am a cad and has forsaken me.\"")
                remove_answer("locket")
                add_answer("lost")
            elseif var_0001 == "Katrina" then
                add_dialogue("\"Katrina is a shepherd here on New Magincia. She has been a friend of mine since I was a boy.\"")
                var_0002 = npc_id_in_party(9) --- Guess: Checks player status
                if var_0002 then
                    switch_talk_to(9)
                    add_dialogue("\"We have had some good memories, have we not, Henry?\"")
                    switch_talk_to(132)
                    add_dialogue("\"Oh that we have! But thou wouldst not be my sweetheart, so we resigned ourselves to being 'just friends' a long time ago, is that not true?\"")
                    switch_talk_to(9)
                    add_dialogue("\"Whatever thou dost say, dear Henry.\"")
                    hide_npc(9)
                    switch_talk_to(132)
                end
                remove_answer("Katrina")
            elseif var_0001 == "lost" then
                add_dialogue("\"I noticed I had lost the locket right after I spoke with those three strangers yesterday. Wouldst thou help me find it?\"")
                var_0003 = select_option()
                if var_0003 then
                    add_dialogue("\"Oh, thank thee, " .. var_0000 .. "! If not for thee, I would be lost.\"")
                    set_flag(381, true)
                else
                    add_dialogue("\"Oh, well... I know thou art busy on thine own quest. I thank thee for listening to my tale, " .. var_0000 .. ".\"")
                end
                remove_answer("lost")
            elseif var_0001 == "strangers" then
                add_dialogue("\"There are three other strangers in New Magincia. They arrived a few days before thee. Their ship was sunk and they barely made it here with their lives.\"")
                remove_answer("strangers")
                set_flag(384, true)
            elseif var_0001 == "found" then
                add_dialogue("\"Thou hast found the locket!\"")
                var_0004 = remove_party_items(true, 2, 359, 955, 1) --- Guess: Deducts item and adds item
                if var_0004 then
                    utility_unknown_1041(50) --- Guess: Submits item or advances quest
                    add_dialogue("You hand the locket to Henry. \"Now I may give it to Constance and keep my promise to her! I cannot thank thee enough, Avatar!\"")
                    set_flag(461, true)
                    var_0004 = npc_id_in_party(9) --- Guess: Checks player status
                    if var_0004 then
                        switch_talk_to(9)
                        add_dialogue("\"I am glad that this situation has concluded in thy favor, dear Henry.\"")
                        switch_talk_to(132)
                        add_dialogue("\"My thanks to thee, Katrina.\"")
                        hide_npc(9)
                        switch_talk_to(132)
                    end
                else
                    add_dialogue("He looks distraught when you make no move to give it to him. \"Where is it?! I need it if I am to prove myself to the woman I love!\"")
                end
                remove_answer("found")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"Travel safely and be well.\"")
    elseif eventid == 0 then
        utility_unknown_1070(132) --- Guess: Triggers a game event
    end
end