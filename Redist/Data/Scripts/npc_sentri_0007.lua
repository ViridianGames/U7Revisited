--- Best guess: Handles dialogue with Sentri in Britain, discussing his role as a combat trainer, with options to join, train, or leave.
function npc_sentri_0007(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    if eventid == 1 then
        switch_talk_to(7)
        var_0000 = get_schedule(7) --- Guess: Checks game state or timer
        var_0001 = is_player_female()
        var_0002 = get_party_members()
        var_0003 = get_npc_name(7) --- Guess: Retrieves object reference from ID
        var_0004 = get_player_name()
        var_0005 = get_schedule_type(7) --- Guess: Gets object state
        add_answer({"bye", "job", "name"})
        if is_int_in_array(var_0003, var_0002) then
            add_answer("leave")
        end
        if not get_flag(26) then
            add_dialogue("You see a dashing, slender man, stylishly dressed, with a lot of flair.")
            set_flag(26, true)
        else
            add_dialogue("\"How may I help thee, " .. var_0004 .. "?\" Sentri asks.")
        end
        while true do
            var_0006 = get_answer()
            if var_0006 == "name" then
                add_dialogue("\"Thou dost not remember me? I am Sentri! We have gone adventuring together in the past!\"")
                remove_answer("name")
            elseif var_0006 == "job" then
                add_dialogue("\"When I am not adventuring with old friends, I am a trainer in Britain. I specialize in combat involving swordsmanship. I am quite good at that, as thou dost remember.\"")
                if not is_int_in_array(var_0003, var_0002) then
                    add_dialogue("\"But I would drop everything to join thy group if thou art not too encumbered.\"")
                    add_answer("join")
                end
                add_answer({"friends", "train", "swordsmanship", "Britain"})
            elseif var_0006 == "friends" then
                add_dialogue("\"I do not see our old friends Iolo, Shamino, or Dupre much.\"")
                remove_answer("friends")
                add_answer({"Dupre", "Shamino", "Iolo"})
            elseif var_0006 == "swordsmanship" then
                add_dialogue("Sentri draws his sword so quickly it is like a flash of lightning. He does a few fancy moves, slashing the air with the blade. \"No foe shall stand after I am finished with him!\"")
                remove_answer("swordsmanship")
            elseif var_0006 == "join" then
                var_0007 = 0
                var_0002 = get_party_members()
                for var_0008 = 1, 8 do
                    var_0007 = var_0007 + 1
                end
                if var_0007 < 6 then
                    add_dialogue("Sentri bows. \"I am very pleased to join thy group.\"")
                    set_flag(219, true)
                    add_to_party(7) --- Guess: Removes object from game
                    add_answer("leave")
                else
                    add_dialogue("\"I like small crowds, Avatar. Thou art travelling with a group too large for my tastes. If thou shouldst lose someone along the way, return and I shall be happy to join thee.\"")
                end
                remove_answer("join")
            elseif var_0006 == "leave" then
                add_dialogue("\"Dost thou want me to wait here or go home?\"")
                save_answers()
                var_000A = ask_answer({"go home", "wait here"})
                if var_000A == "wait here" then
                    add_dialogue("\"Very good. I shall wait here until thou dost return.\"")
                    set_flag(219, false)
                    remove_from_party(7) --- Guess: Sets object state (e.g., active/inactive)
                    set_schedule_type(15, get_npc_name(7)) --- Guess: Sets a generic object property
                    abort()
                else
                    add_dialogue("\"Farewell, " .. var_0004 .. ". If thou dost need my services again, I shall be only too happy to comply.\"")
                    set_flag(219, false)
                    remove_from_party(7) --- Guess: Sets object state (e.g., active/inactive)
                    set_schedule_type(11, get_npc_name(7)) --- Guess: Sets a generic object property
                    abort()
                end
            elseif var_0006 == "Britain" then
                add_dialogue("\"I am becoming weary of the place. It is having growth pains of which the bourgeoisie are unaware. All is not as serene as the noblemen present it.\"")
                remove_answer("Britain")
                add_answer("not serene")
            elseif var_0006 == "not serene" then
                add_dialogue("\"Well, for example, try going to one of the smaller towns, say, Paws. It is a poor man's place. It reeks, too. And 'tis only just beyond the Britain town limits. More money should be put into improving the land as a whole, not just in building new buildings in the capitol city. I do not know what Lord British is thinking!\"")
                remove_answer("not serene")
                add_answer("Lord British")
            elseif var_0006 == "train" then
                if not get_flag(219) then
                    var_0005 = get_schedule_type(7) --- Guess: Gets object state
                    if var_0005 == 27 or var_0005 == 11 or var_0005 == 15 then
                        add_dialogue("\"My fee is 30 gold for a training session. Is this all right?\"")
                        var_000B = select_option()
                        if var_000B then
                            utility_unknown_0997(30, 1) --- Guess: Trains a skill
                        else
                            add_dialogue("\"Then I shall rob someone else!\" Sentri laughs aloud.")
                        end
                    else
                        add_dialogue("\"I am afraid I must adhere to my policy of training only during my business hours. This applies to -all- of my friends.\"")
                        remove_answer("train")
                    end
                else
                    add_dialogue("\"Since I am a member of thy group, I shall train thee for free!\"")
                    utility_unknown_0997(0, 1) --- Guess: Trains a skill
                end
            elseif var_0006 == "Iolo" then
                var_000C = npc_id_in_party(1) --- Guess: Checks player status
                if var_000C then
                    add_dialogue("\"How art thou, friend? Thou dost look like thou couldst use a little training thyself!\"")
                    switch_talk_to(1)
                    add_dialogue("\"What is this? Everyone doth make fun of my physique!\"")
                    hide_npc(1)
                    switch_talk_to(7)
                    add_dialogue("\"I am not making fun, Iolo. I am serious!\" Sentri laughs.")
                else
                    add_dialogue("\"I miss that fellow!\"")
                end
                remove_answer("Iolo")
            elseif var_0006 == "Shamino" then
                var_000D = npc_id_in_party(3) --- Guess: Checks player status
                if var_000D then
                    add_dialogue("\"Say, Shamino, art thou still spending thy time dressing in women's clothes?\"")
                    switch_talk_to(3)
                    add_dialogue("\"-What-?!?!\"")
                    switch_talk_to(7)
                    add_dialogue("\"Or art thou wasting away thy life in a healer's den, now that thou art in thy middle ages?\"")
                    switch_talk_to(3)
                    add_dialogue("\"Careful, friend. Those are fighting words!\"")
                    switch_talk_to(7)
                    add_dialogue("Sentri punches Shamino good-naturedly. \"And that is all they are, my dear friend. Words! 'Tis good to see thee!\"")
                    hide_npc(3)
                else
                    add_dialogue("\"'Twould be good to share a joke or two with him!\"")
                end
                remove_answer("Shamino")
            elseif var_0006 == "Dupre" then
                var_000E = npc_id_in_party(4) --- Guess: Checks player status
                if var_000E then
                    add_dialogue("\"Ah, my good friend Dupre! Hast thou some good ale on thee?\"")
                    switch_talk_to(4)
                    var_000F = check_inventory(3, 359, 616, 1, 4)
                    if var_000F then
                        add_dialogue("\"Art thou joking? I -always- have ale!\"")
                        switch_talk_to(7)
                        add_dialogue("\"Then we should have some before someone else does!\"")
                        switch_talk_to(4)
                        add_dialogue("\"'Twould be a pleasure. However, I must be prudent and save the ale for when we need it.\"")
                        switch_talk_to(7)
                        add_dialogue("Sentri feels of Dupre's head. \"Art thou feeling all right, Dupre? Or has knighthood done something to thy brain?\"")
                    else
                        add_dialogue("\"No, but I would be glad to stop in a pub and share a few pints with thee!\"")
                        switch_talk_to(7)
                        add_dialogue("\"Mmmm! Sounds good to me! Next time we pass a place, let us stop!\"")
                    end
                    hide_npc(4)
                else
                    add_dialogue("\"I want to see that no-good trouble-maker! He is a knight now, I hear! Sir Dupre indeed!\"")
                end
                remove_answer("Dupre")
            elseif var_0006 == "Lord British" then
                add_dialogue("\"I never see him much. He stays in that castle of his all the time. He never gets out. No wonder he hasn't a clue what is going on in this country.\"")
                remove_answer("Lord British")
            elseif var_0006 == "bye" then
                break
            end
        end
        add_dialogue("\"Until later.\"")
    elseif eventid == 0 then
        utility_unknown_1070(7) --- Guess: Triggers a game event
    end
end