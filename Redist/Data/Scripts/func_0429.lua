--- Best guess: Handles dialogue with Candice, the Royal Museum curator, discussing exhibits, Avatar artifacts, and her involvement with The Fellowship, hinting at a secret affair with the Mayor.
function func_0429(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    start_conversation()
    if eventid == 1 then
        switch_talk_to(41, 0)
        var_0000 = unknown_001CH(41) --- Guess: Gets object state
        var_0001 = is_player_wearing_fellowship_medallion() --- Guess: Checks Fellowship membership
        var_0002 = get_schedule() --- Guess: Checks game state or timer
        if var_0002 == 7 then
            var_0003 = unknown_08FCH(26, 41) --- Guess: Checks time for Fellowship meeting
            if var_0003 then
                add_dialogue("Candice is listening intently to the Fellowship meeting.")
                abort()
            else
                if get_flag(218) then
                    add_dialogue("\"Hast thou seen Batlin? He has not shown up for the Fellowship meeting!\"")
                else
                    add_dialogue("\"Oh! I must not stop to speak with thee! I am late for a Fellowship meeting!\"")
                end
                abort()
            end
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(170) then
            add_dialogue("This is a bright woman who looks much younger than she actually is.")
            add_dialogue("\"Well! Thy reputation precedes thee! The Avatar in person! Word has spread that thou wert in Britain!\"")
            set_flag(170, true)
        else
            if var_0002 == 0 then
                var_0004 = unknown_08F7H(43) --- Guess: Checks player status
                if var_0004 then
                    add_dialogue("Candice looks guilty about something. She gives you a little wave, but says nothing. She looks at Patterson, hoping that he will do the talking.")
                    abort()
                else
                    add_dialogue("\"Yes, Avatar?\" Candice says.")
                end
            else
                add_dialogue("\"Yes, Avatar?\" Candice says.")
            end
        end
        while true do
            var_0005 = get_answer()
            if var_0005 == "name" then
                add_dialogue("\"My name is Candice,\" she says brightly. \"I must say I am honored to meet the Avatar!\" She curtsies.")
                remove_answer("name")
            elseif var_0005 == "job" then
                add_dialogue("\"I am the curator of the Royal Museum.\"")
                if var_0000 == 7 then
                    add_dialogue("\"Feel free to ask about any of the exhibits.\"")
                else
                    add_dialogue("\"I hope to see thee there when the museum is open.\"")
                end
                add_dialogue("\"I spend the rest of my time working with The Fellowship.\"")
                add_answer({"Fellowship", "exhibits", "Royal Museum"})
            elseif var_0005 == "Royal Museum" then
                add_dialogue("\"It has been in Britain for many, many years. It contains historical artifacts, as well as works of art.\"")
                remove_answer("Royal Museum")
                add_answer({"works of art", "artifacts"})
            elseif var_0005 == "exhibits" then
                if var_0000 == 7 then
                    add_dialogue("\"We have just opened a special section in which thou might be interested -- an exhibit of 'Avatar artifacts'!\"")
                    add_answer("Avatar artifacts")
                else
                    add_dialogue("\"Come to the museum when it is open!\"")
                end
                remove_answer("exhibits")
            elseif var_0005 == "artifacts" then
                add_dialogue("\"There are relics from early Britannia and even from the Three Ages of Darkness -- back when Britannia was known as Sosaria.\"")
                remove_answer("artifacts")
            elseif var_0005 == "Avatar artifacts" then
                add_dialogue("\"Well, thou surely must recognize them. They are supposed to be authentic! Things like the Silver Horn and the eight stones. I understand the stones were used for teleportation, and if mages were not so sick in the head these days, they could cast a 'Recall' spell on them to teleport to specific places around Britannia. I believe if one casts a 'Mark' spell on one, thou canst re-assign the teleportation location! But I suppose none of that works anymore.\"")
                var_0005 = unknown_08F7H(1) --- Guess: Checks player status
                if var_0005 then
                    switch_talk_to(1, 0)
                    add_dialogue("Iolo whispers to you, \"Er, Avatar, thou dost know that I do not condone stealing. But, er, I do believe these stones may be useful to us. Perhaps we should come back later when the museum is closed, if thou dost know what I mean? After all, these items technically belong to thee!\"")
                    hide_npc(1)
                    switch_talk_to(41, 0)
                end
                remove_answer("Avatar artifacts")
            elseif var_0005 == "works of art" then
                add_dialogue("\"Britannia is proud of the artists who donate their works to the museum. Thou wilt see pieces all over the country by Britannian artists Watson, Richard Fox, Randi Frank, Glen Johnson, and Denis Loubet.\"")
                remove_answer("works of art")
            elseif var_0005 == "Fellowship" then
                if not var_0001 then
                    add_dialogue("\"We meet every evening at the Hall. Thou must come and visit!\"")
                else
                    add_dialogue("\"Thou must know all about it by now! I hope to see thee at an evening meeting!\"")
                end
                add_dialogue("\"The Fellowship has given me a great purpose in life. I have made new friends, and have even found love!\" She giggles. \"Ooops! I gave away my secret! I must not speak of it. Do forget I said that, please?\"")
                remove_answer("Fellowship")
                add_answer({"secret", "purpose"})
            elseif var_0005 == "purpose" then
                add_dialogue("\"I want to attain a higher level of acceptance in The Fellowship. I want to hear the 'voice'. That is mine one true goal.\"")
                remove_answer("purpose")
                add_answer("voice")
            elseif var_0005 == "voice" then
                add_dialogue("\"Dost thou not know? The longer one is a member of The Fellowship, the greater the chances that one will hear the 'voice'. Supposedly, it is a man's voice that thou wilt hear -- perhaps in thy dreams, perhaps while thou art concentrating on something else -- it is a voice that tells thee things, suggests things. I do not know, really. I have not heard it yet, so I am only speaking of what I have heard from others more fortunate than I.\"")
                remove_answer("voice")
                set_flag(140, true)
            elseif var_0005 == "secret" then
                add_dialogue("\"What secret? I do -not- have a secret! It was a slip of the tongue. I cannot really speak to anyone about it. Why, if word got out that the Mayor and I... I mean, uhm, -may- I... er, ask thee to forget that I said anything?\"")
                add_dialogue("Candice turns beet red and turns away.")
                set_flag(128, true)
                abort()
            elseif var_0005 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day, Avatar.\"")
    elseif eventid == 0 then
        unknown_092EH(41) --- Guess: Triggers a game event
    end
end