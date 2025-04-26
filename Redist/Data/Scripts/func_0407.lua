-- Manages Sentri's dialogue in Britain, covering his combat training, views on Britain, and party interactions.

-- Global variables for answer handling
answers = answers or {}
answer = answer or nil

function func_0407(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11

    if eventid == 1 then
        switch_talk_to(-7, 0)
        local0 = get_schedule()
        local1 = is_player_female()
        local2 = get_party_members()
        local3 = switch_talk_to(-7)
        local4 = get_player_name()
        local5 = switch_talk_to(-7)
        local6 = 0

        -- Initialize answers
        answers = {}
        add_answer({"bye", "job", "name"})
        if is_party_member(local3, local2) then
            add_answer("leave")
        end

        if not answer then
            if not get_flag(26) then
                say("You see a dashing, slender man, stylishly dressed, with a lot of flair.")
                set_flag(26, true)
            else
                say("\"How may I help thee, " .. local4 .. "?\" Sentri asks.")
            end
            answer = get_answer()
            return
        end

        -- Process answer
        if answer == "name" then
            say("\"Thou dost not remember me? I am Sentri! We have gone adventuring together in the past!\"")
            remove_answer("name")
        elseif answer == "job" then
            if not get_flag(219) then
                say("\"When I am not adventuring with old friends, I am a trainer in Britain. I specialize in combat involving swordsmanship. I am quite good at that, as thou dost remember.\"")
                say("\"But I would drop everything to join thy group if thou art not too encumbered.\"")
                add_answer("join")
                add_answer({"friends", "train", "swordsmanship", "Britain"})
            else
                say("\"My job is currently to try and keep thee and thy friends out of trouble as much as possible!\" He winks and gives you a good-natured grin.")
                add_answer("friends")
            end
        elseif answer == "friends" then
            say("\"I do not see our old friends Iolo, Shamino, or Dupre much.\"")
            remove_answer("friends")
            add_answer({"Dupre", "Shamino", "Iolo"})
        elseif answer == "swordsmanship" then
            say("Sentri draws his sword so quickly it is like a flash of lightning. He does a few fancy moves, slashing the air with the blade. \"No foe shall stand after I am finished with him!\"")
            remove_answer("swordsmanship")
        elseif answer == "join" then
            local6 = 0
            local2 = get_party_members()
            while local6 < 6 do
                local6 = local6 + 1
            end
            if local6 >= 6 then
                say("Sentri bows. \"I am very pleased to join thy group.\"")
                set_flag(219, true)
                switch_talk_to(-7)
                add_answer("leave")
            else
                say("\"I like small crowds, Avatar. Thou art travelling with a group too large for my tastes. If thou shouldst lose someone along the way, return and I shall be happy to join thee.\"")
            end
            remove_answer("join")
        elseif answer == "leave" then
            say("\"Dost thou want me to wait here or go home?\"")
            answers = {"go home", "wait here"}
            answer = nil
            return
        elseif answer == "go home" then
            say("\"Farewell, " .. local4 .. ". If thou dost need my services again, I shall be only too happy to comply.\"*")
            set_flag(219, false)
            switch_talk_to(-7, 11)
            answers = {}
            answer = nil
            return
        elseif answer == "wait here" then
            say("\"Very good. I shall wait here until thou dost return.\"*")
            set_flag(219, false)
            switch_talk_to(-7, 15)
            answers = {}
            answer = nil
            return
        elseif answer == "Britain" then
            say("\"I am becoming weary of the place. It is having growth pains of which the bourgeoisie are unaware. All is not as serene as the noblemen present it.\"")
            remove_answer("Britain")
            add_answer("not serene")
        elseif answer == "not serene" then
            say("\"Well, for example, try going to one of the smaller towns, say, Paws. It is a poor man's place. It reeks, too. And 'tis only just beyond the Britain town limits. More money should be put into improving the land as a whole, not just in building new buildings in the capitol city. I do not know what Lord British is thinking!\"")
            remove_answer("not serene")
            add_answer("Lord British")
        elseif answer == "train" then
            if not get_flag(219) then
                local5 = switch_talk_to(-7)
                if local5 == 27 or local5 == 11 or local5 == 15 then
                    say("\"My fee is 30 gold for a training session. Is this all right?\"")
                    answers = {true, false}
                    answer = nil
                    return
                else
                    say("\"I am afraid I must adhere to my policy of training only during my business hours. This applies to -all- of my friends.\"")
                    remove_answer("train")
                end
            else
                say("\"Since I am a member of thy group, I shall train thee for free!\"")
                apply_effect(0, 1)
            end
        elseif answer == true then
            apply_effect(30, 1)
        elseif answer == false then
            say("\"Then I shall rob someone else!\" Sentri laughs aloud.")
        elseif answer == "Iolo" then
            local11 = get_item_type(-1)
            if local11 then
                say("\"How art thou, friend? Thou dost look like thou couldst use a little training thyself!\"*")
                switch_talk_to(-1, 0)
                say("\"What is this? Everyone doth make fun of my physique!\"*")
                hide_npc(-1)
                switch_talk_to(-7, 0)
                say("\"I am not making fun, Iolo. I am serious!\" Sentri laughs.")
            else
                say("\"I miss that fellow!\"")
            end
            remove_answer("Iolo")
        elseif answer == "Shamino" then
            local11 = get_item_type(-3)
            if local11 then
                say("\"Say, Shamino, art thou still spending thy time dressing in women's clothes?\"*")
                switch_talk_to(-3, 0)
                say("\"-What-?!?!\"*")
                switch_talk_to(-7, 0)
                say("\"Or art thou wasting away thy life in a healer's den, now that thou art in thy middle ages?\"*")
                switch_talk_to(-3, 0)
                say("\"Careful, friend. Those are fighting words!\"*")
                switch_talk_to(-7, 0)
                say("Sentri punches Shamino good-naturedly. \"And that is all they are, my dear friend. Words! 'Tis good to see thee!\"")
                hide_npc(-3)
            else
                say("\"'Twould be good to share a joke or two with him!\"")
            end
            remove_answer("Shamino")
        elseif answer == "Dupre" then
            local11 = get_item_type(-4)
            if local11 then
                say("\"Ah, my good friend Dupre! Hast thou some good ale on thee?\"*")
                if has_item(3, -359, 616, 1, -4) then
                    say("\"Art thou joking? I -always- have ale!\"*")
                    switch_talk_to(-7, 0)
                    say("\"Then we should have some before someone else does!\"")
                    switch_talk_to(-4, 0)
                    say("\"'Twould be a pleasure. However, I must be prudent and save the ale for when we need it.\"*")
                    switch_talk_to(-7, 0)
                    say("Sentri feels of Dupre's head. \"Art thou feeling all right, Dupre? Or has knighthood done something to thy brain?\"")
                else
                    say("\"No, but I would be glad to stop in a pub and share a few pints with thee!\"*")
                    switch_talk_to(-7, 0)
                    say("\"Mmmm! Sounds good to me! Next time we pass a place, let us stop!\"")
                end
                hide_npc(-4)
            else
                say("\"I want to see that no-good trouble-maker! He is a knight now, I hear! Sir Dupre indeed!\"")
            end
            remove_answer("Dupre")
        elseif answer == "Lord British" then
            say("\"I never see him much. He stays in that castle of his all the time. He never gets out. No wonder he hasn't a clue what is going on in this country.\"")
            remove_answer("Lord British")
        elseif answer == "bye" then
            say("\"Until later.\"*")
            answers = {}
            answer = nil
            return
        end

        -- Clear answer if not handled
        answer = nil
        return
    elseif eventid == 0 then
        switch_talk_to(-7)
        answers = {}
        answer = nil
    end
    return
end