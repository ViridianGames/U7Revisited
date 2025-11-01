--- Best guess: Handles dialogue with Garritt, a young Fellowship member in Paws, covering his aspirations, family, and involvement in framing Tobias for venom theft, with playful taunts for eventid 0.
function npc_garritt_0171(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        start_conversation()
        switch_talk_to(171) --- Guess: Switches dialogue target
        var_0000 = get_lord_or_lady() --- External call to get lord or lady title
        var_0001 = get_dialogue_context() --- Guess: Gets dialogue context
        add_answer({"bye", "job", "name"}) --- Guess: Adds dialogue options
        if not get_flag(540) then
            add_answer("Tobias") --- Guess: Adds dialogue option
        end
        var_0002 = check_object_conditions(1, 359, 649, 1, 357) --- External call to check item conditions
        if var_0002 then
            add_answer("found venom") --- Guess: Adds dialogue option
        end
        if not get_flag(548) then
            add_dialogue("@You see a jovial young man who gives you a friendly greeting.@")
            set_flag(548, true)
        else
            add_dialogue("@A pleasant day to thee, " .. var_0000 .. ",\" says Garritt.@")
        end
        while true do
            var_0003 = get_answer() --- Guess: Gets conversation answer
            if var_0003 == "name" then
                add_dialogue("@I am Garritt, the son of Feridwyn and Brita.@")
                add_answer({"Brita", "Feridwyn"}) --- Guess: Adds dialogue options
                remove_answer("name") --- Guess: Removes dialogue option
            elseif var_0003 == "job" then
                add_dialogue("@I am too young to learn a trade of mine own yet, but I do assist my parents in running the shelter. I hope to be a counselor in The Fellowship one day. Or a professional whistle panpipes player.@")
                add_answer({"panpipes", "Fellowship", "shelter"}) --- Guess: Adds dialogue options
            elseif var_0003 == "Feridwyn" then
                add_dialogue("@My father works for The Fellowship helping the poor people in Paws. He tries to recruit them, but most refuse.@")
                remove_answer("Feridwyn") --- Guess: Removes dialogue option
                add_answer({"poor people", "recruit", "Paws"}) --- Guess: Adds dialogue options
            elseif var_0003 == "Paws" then
                add_dialogue("@Actually, I do not like this town very much. The people here are all poor and the only one mine own age is Tobias.@")
                if not get_flag(536) then
                    add_dialogue("@And,\" he adds, \"there is a thief here.@")
                    add_answer("thief") --- Guess: Adds dialogue option
                end
                remove_answer("Paws") --- Guess: Removes dialogue option
                add_answer("Tobias") --- Guess: Adds dialogue option
            elseif var_0003 == "panpipes" then
                add_dialogue("@I have been playing panpipes since I was little. I'm pretty good now, if I say so myself! I keep the whistle by my bed and practice every night before going to sleep!@")
                remove_answer("panpipes") --- Guess: Removes dialogue option
            elseif var_0003 == "Tobias" then
                if get_flag(536) then
                    add_dialogue("@I may not have told the truth about Tobias stealing the venom, but I know that he is up to no good. He shall come to a bad end, just thou wait and see!@")
                elseif not get_flag(540) then
                    add_dialogue("@He and his mother reject The Fellowship. They are witless and stupid and I do not like them.@")
                else
                    add_dialogue("@I have said it a thousand times. Tobias is weak of character! He and his mother are poor because they are lazy. Now I am proven right because Tobias is a thief. A thief who has been caught!@")
                end
                remove_answer("Tobias") --- Guess: Removes dialogue option
            elseif var_0003 == "recruit" then
                add_dialogue("@My father was once the head recruiter in Britain until they moved him here. I once heard him talking to mother about how The Fellowship was wasting its time here.@")
                remove_answer("recruit") --- Guess: Removes dialogue option
            elseif var_0003 == "poor people" then
                add_dialogue("@My father says that the poor people reject The Fellowship because the Triad of Inner Strength requires strength of character.@")
                remove_answer("poor people") --- Guess: Removes dialogue option
                add_answer("character") --- Guess: Adds dialogue option
            elseif var_0003 == "character" then
                add_dialogue("@My father says the poor are weak of character and that is why they are poor. They do not have to be. They are just too lazy to work. Dost thou agree?@")
                var_0004 = get_dialogue_choice() --- Guess: Gets dialogue choice
                if not var_0004 then
                    add_dialogue("@I was not so sure, but since that is what my father says, it must be true.@")
                elseif var_0001 then
                    add_dialogue("@Hmpf. For a Fellowship member, thou dost lack recognition. Thou dost not understand the teachings of The Fellowship.@")
                else
                    add_dialogue("@Then thou must be a person of weak character, also.@")
                end
                remove_answer("character") --- Guess: Removes dialogue option
            elseif var_0003 == "Brita" then
                add_dialogue("@Oh, she is just my mother. She does whatever my father doth tell her to do.@")
                remove_answer("Brita") --- Guess: Removes dialogue option
            elseif var_0003 == "shelter" then
                add_dialogue("@Plenty of beds are available if thou wouldst like to stay in the shelter,\" he says with a condescending tone.@")
                remove_answer("shelter") --- Guess: Removes dialogue option
            elseif var_0003 == "Fellowship" then
                if var_0001 then
                    add_dialogue("@I am a member and I am proud to say I recruit for them as well.@")
                else
                    add_dialogue("@Oh, I can tell thee all thou dost need to know about us!@")
                    describe_fellowship() --- External call to describe Fellowship
                    add_answer("philosophy") --- Guess: Adds dialogue option
                end
                remove_answer("Fellowship") --- Guess: Removes dialogue option
            elseif var_0003 == "philosophy" then
                add_dialogue("@I am also quite knowledgeable when it comes to our philosophy. We follow the Triad of Inner Strength and do let personal failures get in our way or slow us down.@")
                add_dialogue("@Dost thou want to join?@")
                var_0005 = get_dialogue_choice() --- Guess: Gets dialogue choice
                if var_0005 then
                    add_dialogue("@I got another one!\" he says gleefully. \"Thou must speak with my father right away!@")
                else
                    add_dialogue("@Contemplate it for the nonce, then.@")
                end
                remove_answer("philosophy") --- Guess: Removes dialogue option
            elseif var_0003 == "found venom" then
                set_quest_property(150) --- External call to set quest property
                add_dialogue("@Thou hast found me out! Yes, it was I who planted the venom on Tobias. He did deserve it! I beg thee, please do not tell my parents!@")
                set_flag(536, true)
                add_answer({"parents", "planted"}) --- Guess: Adds dialogue options
                remove_answer("found venom") --- Guess: Removes dialogue option
            elseif var_0003 == "planted" then
                add_dialogue("@I stole the venom from Morfin so I could put the blame on Tobias.@")
                add_answer("Morfin") --- Guess: Adds dialogue option
                remove_answer("planted") --- Guess: Removes dialogue option
            elseif var_0003 == "Morfin" then
                add_dialogue("@I do not know why Morfin has it or what he does with it. I only knew that it was valuable and that it would cause everyone worry if it were stolen.@")
                add_dialogue("Garritt does not meet your eyes. You instinctively know he is not telling the truth and may very well be using the venom.")
                remove_answer("Morfin") --- Guess: Removes dialogue option
                add_answer({"using venom?", "worry"}) --- Guess: Adds dialogue options
            elseif var_0003 == "using venom?" then
                add_dialogue("Garritt shuffles his feet and frowns. \"Well... I tried it just once. I am sorry. I will never use it again.\"")
                remove_answer("using venom?") --- Guess: Removes dialogue option
            elseif var_0003 == "worry" then
                add_dialogue("@I thought that if Tobias were accused of stealing something that everyone would notice, his mother would join The Fellowship and force him to join, too. It would improve their lives and force them to see the truth about themselves.@")
                remove_answer("worry") --- Guess: Removes dialogue option
            elseif var_0003 == "parents" then
                add_dialogue("@Wilt thou tell my parents?@")
                var_0005 = get_dialogue_choice() --- Guess: Gets dialogue choice
                if var_0005 then
                    if var_0001 then
                        add_dialogue("@But I, like thee, am a member of The Fellowship. Thou must stand in unity with me for what I tried to do!@")
                        remove_answer("parents") --- Guess: Removes dialogue option
                    else
                        add_dialogue("@Thou art weak of character! Or otherwise thou wouldst understand what I tried to do!@")
                    end
                else
                    add_dialogue("@I thank thee most enthusiastically! It will be our little secret then.@")
                    set_flag(537, true)
                end
                remove_answer("parents") --- Guess: Removes dialogue option
            elseif var_0003 == "thief" then
                add_dialogue("@There is a thief in this town! Our merchant Morfin had some valuable silver serpent venom stolen from him. The culprit is still free. So be wary!@")
                set_flag(532, true)
                remove_answer("thief") --- Guess: Removes dialogue option
            elseif var_0003 == "bye" then
                add_dialogue("@Goodbye, then.@")
                if not get_flag(536) then
                    set_object_attribute(get_object_owner(171), 25) --- Guess: Sets item attribute
                end
                break
            end
        end
    elseif eventid == 0 then
        var_0006 = get_object_attribute(get_object_owner(171)) --- Guess: Gets item attribute
        var_0007 = random(1, 4) --- Guess: Generates random number
        if var_0006 == 25 then
            if var_0007 == 1 then
                var_0008 = "@Nyah nyah!@"
            elseif var_0007 == 2 then
                var_0008 = "@Cannot catch me!@"
            elseif var_0007 == 3 then
                var_0008 = "@Catch me if thou can!@"
            elseif var_0007 == 4 then
                var_0008 = "@Tag! Thou art it!@"
            end
            bark(171, var_0008) --- Guess: Item says dialogue
        else
            move_npc(171) --- External call to move NPC
        end
    end
end