--- Best guess: Handles dialogue with Katrina in New Magincia, discussing her life as a shepherd, local visitors, and a locket given to Henry, with options to join or leave.
function func_0409(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    if eventid == 1 then
        switch_talk_to(9, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = get_party_members()
        var_0002 = unknown_001BH(9) --- Guess: Retrieves object reference from ID
        var_0003 = get_player_name()
        var_0004 = unknown_08F7H(3) --- Guess: Checks player status
        var_0005 = unknown_08F7H(1) --- Guess: Checks player status
        var_0006 = unknown_08F7H(4) --- Guess: Checks player status
        add_answer({"bye", "job", "name"})
        if is_in_int_array(var_0002, var_0001) then
            add_answer("leave")
        end
        if not get_flag(397) then
            add_answer("Henry")
        end
        if not get_flag(381) then
            add_answer("locket")
        end
        if not get_flag(384) then
            add_answer("strangers")
        end
        if not get_flag(28) then
            add_dialogue("You see your old companion Katrina looking only slightly older than when you saw her during your last visit.")
            set_flag(28, true)
        else
            add_dialogue("\"Hello again, " .. var_0003 .. "!\" Katrina greets you with a smile.")
        end
        while true do
            var_0007 = get_answer()
            if var_0007 == "name" then
                add_dialogue("\"Why,\" she blinks at you, \"I know it has been a long time, but surely thou cannot have forgotten me. I am Katrina. One of thine old companions.\"")
                add_dialogue("You share a friendly laugh at your reunion.")
                add_answer({"time", "old companions"})
                remove_answer("name")
            elseif var_0007 == "old companions" then
                add_dialogue("\"Ah, yes, Iolo, Shamino, and Dupre.\"")
                remove_answer("old companions")
               明星  add_answer({"Dupre", "Shamino", "Iolo"})
            elseif var_0007 == "time" then
                add_dialogue("\"Although there is a vast difference in how time passes in our world and in this one, I am certain I have aged at least a bit,\" she says pleasantly.")
                remove_answer("time")
            elseif var_0007 == "job" then
                if not is_in_int_array(var_0002, var_0001) then
                    add_dialogue("\"Why, after last accompanying thee on thine adventures I settled down to the peaceful life of a shepherd in New Magincia.\"")
                    add_answer({"New Magincia", "shepherd"})
                    if not is_in_int_array(var_0002, var_0001) then
                        add_dialogue("\"If thou dost have need of me I could join thy party again.\"")
                        add_answer("join")
                    end
                else
                    add_dialogue("\"Following thee around, " .. var_0000 .. "! I shall never miss New Magincia!\"")
                    add_answer("New Magincia")
                end
            elseif var_0007 == "shepherd" then
                add_dialogue("\"I watch over my flock, and the townspeople as well, when they need me.\"")
                remove_answer("shepherd")
            elseif var_0007 == "join" then
                var_0008 = 0
                var_0001 = get_party_members()
                for var_0009 = 1, 8 do
                    var_0008 = var_0008 + 1
                end
                if var_0008 < 6 then
                    add_dialogue("\"It would be an honor, " .. var_0000 .. "!\"")
                    unknown_001EH(9) --- Guess: Removes object from game
                    add_answer("leave")
                    remove_answer("join")
                else
                    add_dialogue("\"I prefer smaller crowds, Avatar. Perhaps later.\"")
                end
                remove_answer("join")
            elseif var_0007 == "leave" then
                add_dialogue("\"Dost thou want me to wait here or shall I go on home?\"")
                save_answers()
                var_000B = ask_answer({"go home", "wait here"})
                if var_000B == "wait here" then
                    add_dialogue("\"I shall be happy to wait here until thou dost return.\"")
                    unknown_001FH(9) --- Guess: Sets object state (e.g., active/inactive)
                    unknown_001DH(15, unknown_001BH(9)) --- Guess: Sets a generic object property
                    abort()
                else
                    add_dialogue("\"If thou dost think it best, I shall. If thou dost need me again thou dost have but to ask.\"")
                    unknown_001FH(9) --- Guess: Sets object state (e.g., active/inactive)
                    unknown_001DH(11, unknown_001BH(9)) --- Guess: Sets a generic object property
                    abort()
                end
            elseif var_0007 == "New Magincia" then
                add_dialogue("\"We are isolated here. We get no news from the world outside. Life is much the same as it was the last time thou didst visit Britannia two hundred years ago. I have many friends here.\"")
                add_answer("isolated")
                remove_answer("New Magincia")
            elseif var_0007 == "isolated" then
                add_dialogue("\"That is the way we like it here. Now we have three other strangers on the island -- besides thee. Of course, thou couldst hardly be called a stranger. This is the largest number of visitors we have had in years.~~But, never fear, " .. var_0003 .. ", I am seldom lonely.\"")
                remove_answer("isolated")
                add_answer({"visitors", "lonely"})
            elseif var_0007 == "lonely" then
                add_dialogue("\"I have many friends here. When I am lonely, I speak with Alagner the Sage, Russell the shipwright, or Henry the peddler.\"")
                remove_answer("lonely")
                add_answer({"Henry", "Russell", "Alagner"})
            elseif var_0007 == "Alagner" then
                add_dialogue("\"He is a wise man who knows many things and tells wonderful stories. Alagner came here to retreat from the outside world. I know not why.\"")
                remove_answer("Alagner")
            elseif var_0007 == "Russell" then
                add_dialogue("\"He has a sailor's heart, an artist's soul and a craftsman's hands. He never lived his dream of sailing the world. His ships do that for him.\"")
                remove_answer("Russell")
            elseif var_0007 == "Henry" then
                add_dialogue("\"Henry has been a very dear friend for years. He is a simple but good man who does not have an ounce of hate in his heart for anyone. I am so fond of him that I gave him a valuable heirloom.\"")
                remove_answer("Henry")
                add_answer("heirloom")
            elseif var_0007 == "heirloom" or var_0007 == "locket" then
                add_dialogue("\"Since he does not have much money, I gave Henry my gold locket so he could present it to his sweetheart Constance. I have not talked to him lately, but I must confess I am worried about him.\"")
                remove_answer({"locket", "heirloom"})
                add_answer("worried")
            elseif var_0007 == "worried" then
                add_dialogue("\"Soon after Henry left carrying the locket, I saw the three strangers on the island, wandering off in the same direction.\"")
                remove_answer("worried")
            elseif var_0007 == "strangers" or var_0007 == "visitors" then
                add_dialogue("\"The three visitors come from Buccaneer's Den. I met them shortly after their arrival and we spoke briefly. Robin is the one dressed like a gambler and the other two, Battles and Leavell, appear to be bullies.\"")
                remove_answer({"visitors", "strangers"})
                set_flag(384, true)
            elseif var_0007 == "Iolo" then
                if not var_0005 then
                    add_dialogue("\"Iolo should be in our party adventuring with us.\"")
                else
                    add_dialogue("\"How hast thou been keeping thyself all these years, Iolo?\"")
                    switch_talk_to(1, 0)
                    add_dialogue("\"The years have not been as kind to me as they obviously have been to thee, milady.\"")
                    switch_talk_to(9, 0)
                    add_dialogue("\"Ha! I see thou art still a scallywag, Iolo.\"")
                    hide_npc(1)
                    switch_talk_to(9, 0)
                end
                remove_answer("Iolo")
            elseif var_0007 == "Shamino" then
                if not var_0004 then
                    add_dialogue("\"Shamino should be here with us.\"")
                else
                    add_dialogue("\"Is that a gray hair I see in thine hair, Shamino?\"")
                    switch_talk_to(3, 0)
                    add_dialogue("\"It is not! Where?\"")
                    switch_talk_to(9, 0)
                    add_dialogue("\"Perhaps it is but a trick of the light.\"")
                    hide_npc(3)
                    switch_talk_to(9, 0)
                end
                remove_answer("Shamino")
            elseif var_0007 == "Dupre" then
                if not var_0006 then
                    add_dialogue("\"I cannot help but miss Dupre a little. I have not seen him since he was knighted.\"")
                else
                    add_dialogue("\"Sir Dupre, hast thou finished thy studies yet?\"")
                    switch_talk_to(4, 0)
                    add_dialogue("Dupre looks confounded. \"My studies, milady?\"")
                    switch_talk_to(9, 0)
                    add_dialogue("\"Of all the various drinking establishments in Britannia!\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"Oh, yes, of course, my studies! Continuing mine education has always been of the utmost importance to me.\"")
                    hide_npc(4)
                    switch_talk_to(9, 0)
                end
                remove_answer("Dupre")
            elseif var_0007 == "bye" then
                break
            end
        end
        add_dialogue("\"Pleasant days, " .. var_0003 .. ".\"")
    elseif eventid == 0 then
        unknown_092EH(9) --- Guess: Triggers a game event
    end
end