-- Manages Katrina's dialogue in New Magincia, covering her shepherd role, friend Henry, island strangers, and party joining.
function func_0409(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11

    if eventid == 1 then
        switch_talk_to(-9, 0)
        local0 = get_player_name()
        local1 = get_party_members()
        local2 = switch_talk_to(-9)
        local3 = get_player_name()
        local4 = get_item_type(-3)
        local5 = get_item_type(-1)
        local6 = get_item_type(-4)
        local7 = 0

        add_answer({"bye", "job", "name"})
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
            say("You see your old companion Katrina looking only slightly older than when you saw her during your last visit.")
            set_flag(28, true)
        else
            say("\"Hello again, " .. local3 .. "!\" Katrina greets you with a smile.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"Why,\" she blinks at you, \"I know it has been a long time, but surely thou cannot have forgotten me. I am Katrina. One of thine old companions.\"")
                say("You share a friendly laugh at your reunion.")
                add_answer({"time", "old companions"})
                remove_answer("name")
            elseif answer == "old companions" then
                say("\"Ah, yes, Iolo, Shamino, and Dupre.\"")
                remove_answer("old companions")
                add_answer({"Dupre", "Shamino", "Iolo"})
            elseif answer == "time" then
                say("\"Although there is a vast difference in how time passes in our world and in this one, I am certain I have aged at least a bit,\" she says pleasantly.")
                remove_answer("time")
            elseif answer == "job" then
                if not is_party_member(local2, local1) then
                    say("\"Why, after last accompanying thee on thine adventures I settled down to the peaceful life of a shepherd in New Magincia.\"")
                    add_answer({"New Magincia", "shepherd"})
                    if not is_party_member(local2, local1) then
                        say("\"If thou dost have need of me I could join thy party again.\"")
                        add_answer("join")
                    end
                else
                    say("\"Following thee around, " .. local0 .. "! I shall never miss New Magincia!\"")
                    add_answer("New Magincia")
                end
            elseif answer == "shepherd" then
                say("\"I watch over my flock, and the townspeople as well, when they need me.\"")
                remove_answer("shepherd")
            elseif answer == "join" then
                local7 = 0
                local1 = get_party_members()
                while local7 < 6 do
                    local7 = local7 + 1
                end
                if local7 >= 6 then
                    say("\"It would be an honor, " .. local0 .. "!\"")
                    switch_talk_to(-9)
                    add_answer("leave")
                    remove_answer("join")
                else
                    say("\"I prefer smaller crowds, Avatar. Perhaps later.\"")
                end
                remove_answer("join")
            elseif answer == "leave" then
                say("\"Dost thou want me to wait here or shall I go on home?\"")
                local answers = {"go home", "wait here"}
                local11 = get_answer(answers)
                if local11 == "wait here" then
                    say("\"I shall be happy to wait here until thou dost return.\"*")
                    switch_talk_to(-9, 15)
                    return
                else
                    say("\"If thou dost think it best, I shall. If thou dost need me again thou dost have but to ask.\"*")
                    switch_talk_to(-9, 11)
                    return
                end
            elseif answer == "New Magincia" then
                say("\"We are isolated here. We get no news from the world outside. Life is much the same as it was the last time thou didst visit Britannia two hundred years ago. I have many friends here.\"")
                add_answer("isolated")
                remove_answer("New Magincia")
            elseif answer == "isolated" then
                say("\"That is the way we like it here. Now we have three other strangers on the island -- besides thee. Of course, thou couldst hardly be called a stranger. This is the largest number of visitors we have had in years.~~But, never fear, " .. local3 .. ", I am seldom lonely.\"")
                remove_answer("isolated")
                add_answer({"visitors", "lonely"})
            elseif answer == "lonely" then
                say("\"I have many friends here. When I am lonely, I speak with Alagner the Sage, Russell the shipwright, or Henry the peddler.\"")
                remove_answer("lonely")
                add_answer({"Henry", "Russell", "Alagner"})
            elseif answer == "Alagner" then
                say("\"He is a wise man who knows many things and tells wonderful stories. Alagner came here to retreat from the outside world. I know not why.\"")
                remove_answer("Alagner")
            elseif answer == "Russell" then
                say("\"He has a sailor's heart, an artist's soul and a craftsman's hands. He never lived his dream of sailing the world. His ships do that for him.\"")
                remove_answer("Russell")
            elseif answer == "Henry" then
                say("\"Henry has been a very dear friend for years. He is a simple but good man who does not have an ounce of hate in his heart for anyone. I am so fond of him that I gave him a valuable heirloom.\"")
                remove_answer("Henry")
                add_answer("heirloom")
            elseif answer == "heirloom" or answer == "locket" then
                say("\"Since he does not have much money, I gave Henry my gold locket so he could present it to his sweetheart Constance. I have not talked to him lately, but I must confess I am worried about him.\"")
                remove_answer({"locket", "heirloom"})
                add_answer("worried")
            elseif answer == "worried" then
                say("\"Soon after Henry left carrying the locket, I saw the three strangers on the island, wandering off in the same direction.\"")
                remove_answer("worried")
            elseif answer == "strangers" or answer == "visitors" then
                say("\"The three visitors come from Buccaneer's Den. I met them shortly after their arrival and we spoke briefly. Robin is the one dressed like a gambler and the other two, Battles and Leavell, appear to be bullies.\"")
                remove_answer({"visitors", "strangers"})
                set_flag(384, true)
            elseif answer == "Iolo" then
                if not local5 then
                    say("\"Iolo should be in our party adventuring with us.\"")
                else
                    say("\"How hast thou been keeping thyself all these years, Iolo?\"*")
                    switch_talk_to(-1, 0)
                    say("\"The years have not been as kind to me as they obviously have been to thee, milady.\"*")
                    switch_talk_to(-9, 0)
                    say("\"Ha! I see thou art still a scallywag, Iolo.\"*")
                    hide_npc(-1)
                end
                remove_answer("Iolo")
            elseif answer == "Shamino" then
                if not local4 then
                    say("\"Shamino should be here with us.\"")
                else
                    say("\"Is that a gray hair I see in thine hair, Shamino?\"*")
                    switch_talk_to(-3, 0)
                    say("\"It is not! Where?\"*")
                    switch_talk_to(-9, 0)
                    say("\"Perhaps it is but a trick of the light.\"*")
                    hide_npc(-3)
                end
                remove_answer("Shamino")
            elseif answer == "Dupre" then
                if not local6 then
                    say("\"I cannot help but miss Dupre a little. I have not seen him since he was knighted.\"")
                else
                    say("\"Sir Dupre, hast thou finished thy studies yet?\"*")
                    switch_talk_to(-4, 0)
                    say("Dupre looks confounded. \"My studies, milady?\"*")
                    switch_talk_to(-9, 0)
                    say("\"Of all the various drinking establishments in Britannia!\"*")
                    switch_talk_to(-4, 0)
                    say("\"Oh, yes, of course, my studies! Continuing mine education has always been of the utmost importance to me.\"*")
                    hide_npc(-4)
                end
                remove_answer("Dupre")
            elseif answer == "bye" then
                say("\"Pleasant days, " .. local3 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-9)
    end
    return
end