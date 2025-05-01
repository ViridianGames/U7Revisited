-- Manages Candice's dialogue in Britain, covering Royal Museum curation, Fellowship involvement, and secret affair with Patterson.
function func_0429(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        switch_talk_to(41, 0)
        local0 = switch_talk_to(41)
        local1 = get_item_type()
        local2 = get_schedule()

        if local2 == 7 then
            local3 = apply_effect(-26, -41) -- Unmapped intrinsic 08FC
            if local3 then
                add_dialogue("Candice is listening intently to the Fellowship meeting.*")
                return
            elseif get_flag(218) then
                add_dialogue("\"Hast thou seen Batlin? He has not shown up for the Fellowship meeting!\"")
            else
                add_dialogue("\"Oh! I must not stop to speak with thee! I am late for a Fellowship meeting!\"*")
                return
            end
        end

        add_answer({"bye", "job", "name"})

        if not get_flag(170) then
            add_dialogue("This is a bright woman who looks much younger than she actually is.")
            add_dialogue("\"Well! Thy reputation precedes thee! The Avatar in person! Word has spread that thou wert in Britain!\"")
            set_flag(170, true)
        elseif local2 == 0 then
            local4 = get_item_type(-43)
            if local4 then
                add_dialogue("Candice looks guilty about something. She gives you a little wave, but says nothing. She looks at Patterson, hoping that he will do the talking.*")
                return
            else
                add_dialogue("\"Yes, Avatar?\" Candice says.")
            end
        else
            add_dialogue("\"Yes, Avatar?\" Candice says.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Candice,\" she says brightly. \"I must say I am honored to meet the Avatar!\" She curtsies.")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the curator of the Royal Museum.\"")
                if local0 == 7 then
                    add_dialogue("\"Feel free to ask about any of the exhibits.\"")
                else
                    add_dialogue("\"I hope to see thee there when the museum is open.\"")
                end
                add_dialogue("\"I spend the rest of my time working with The Fellowship.\"")
                add_answer({"Fellowship", "exhibits", "Royal Museum"})
            elseif answer == "Royal Museum" then
                add_dialogue("\"It has been in Britain for many, many years. It contains historical artifacts, as well as works of art.\"")
                remove_answer("Royal Museum")
                add_answer({"works of art", "artifacts"})
            elseif answer == "exhibits" then
                if local0 == 7 then
                    add_dialogue("\"We have just opened a special section in which thou might be interested -- an exhibit of 'Avatar artifacts'!\"")
                    add_answer("Avatar artifacts")
                else
                    add_dialogue("\"Come to the museum when it is open!\"")
                end
                remove_answer("exhibits")
            elseif answer == "artifacts" then
                add_dialogue("\"There are relics from early Britannia and even from the Three Ages of Darkness -- back when Britannia was known as Sosaria.\"")
                remove_answer("artifacts")
            elseif answer == "Avatar artifacts" then
                add_dialogue("\"Well, thou surely must recognize them. They are supposed to be authentic! Things like the Silver Horn and the eight stones. I understand the stones were used for teleportation, and if mages were not so sick in the head these days, they could cast a 'Recall' spell on them to teleport to specific places around Britannia. I believe if one casts a 'Mark' spell on one, thou canst re-assign the teleportation location! But I suppose none of that works anymore.\"")
                local5 = get_item_type(-1)
                if local5 then
                    switch_talk_to(1, 0)
                    add_dialogue("Iolo whispers to you, \"Er, Avatar, thou dost know that I do not condone stealing. But, er, I do believe these stones may be useful to us. Perhaps we should come back later when the museum is closed, if thou dost know what I mean? After all, these items technically belong to thee!\"")
                    hide_npc(1)
                    switch_talk_to(41, 0)
                end
                remove_answer("Avatar artifacts")
            elseif answer == "works of art" then
                add_dialogue("\"Britannia is proud of the artists who donate their works to the museum. Thou wilt see pieces all over the country by Britannian artists Watson, Richard Fox, Randi Frank, Glen Johnson, and Denis Loubet.\"")
                remove_answer("works of art")
            elseif answer == "Fellowship" then
                if not local1 then
                    add_dialogue("\"We meet every evening at the Hall. Thou must come and visit!\"")
                else
                    add_dialogue("\"Thou must know all about it by now! I hope to see thee at an evening meeting!\"")
                end
                add_dialogue("\"The Fellowship has given me a great purpose in life. I have made new friends, and have even found love!\" She giggles. \"Ooops! I gave away my secret! I must not speak of it. Do forget I said that, please?\"")
                remove_answer("Fellowship")
                add_answer({"secret", "purpose"})
            elseif answer == "purpose" then
                add_dialogue("\"I want to attain a higher level of acceptance in The Fellowship. I want to hear the 'voice'. That is mine one true goal.\"")
                remove_answer("purpose")
                add_answer("voice")
            elseif answer == "voice" then
                add_dialogue("\"Dost thou not know? The longer one is a member of The Fellowship, the greater the chances that one will hear the 'voice'. Supposedly, it is a man's voice that thou wilt hear -- perhaps in thy dreams, perhaps while thou art concentrating on something else -- it is a voice that tells thee things, suggests things. I do not know, really. I have not heard it yet, so I am only speaking of what I have heard from others more fortunate than I.\"")
                remove_answer("voice")
                set_flag(140, true)
            elseif answer == "secret" then
                add_dialogue("\"What secret? I do -not- have a secret! It was a slip of the tongue. I cannot really speak to anyone about it. Why, if word got out that the Mayor and I... I mean, uhm, -may- I... er, ask thee to forget that I said anything?\"~~Candice turns beet red and turns away.*")
                set_flag(128, true)
                return
            elseif answer == "bye" then
                add_dialogue("\"Good day, Avatar.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(41)
    end
    return
end