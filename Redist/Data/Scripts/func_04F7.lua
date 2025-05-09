--- Best guess: Manages Caine’s dialogue in Skara Brae, the Tortured One, a ghostly alchemist tormented by his failure to destroy the Liche, providing potion instructions and answers to life and death questions if freed.
function func_04F7(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        switch_talk_to(0, 247)
        if not get_flag(434) then
            add_dialogue("The non-corporeal man stares past you, seemingly past the confines of the building, and, perhaps, of the world. Then, he suddenly shudders, as if he is filled with pain.")
            return
        end
        var_0000 = false
        var_0001 = false
        var_0002 = false
        var_0003 = unknown_0909H()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(450) then
            add_dialogue("The ghostly man displays a face filled with pain.")
            set_flag(450, true)
        else
            add_dialogue("\"Greetings, " .. var_0003 .. ".\" Caine breathes deeply, apparently forcing back his torment.")
            if not get_flag(380) and not get_flag(406) then
                add_answer("questions")
                var_0002 = true
            end
            if not get_flag(447) then
                if not get_flag(448) then
                    add_answer("need formula")
                    var_0001 = true
                end
            end
            if not get_flag(464) then
                if not get_flag(465) then
                    add_answer("instructions")
                end
            end
            if not get_flag(408) then
                if not get_flag(417) then
                    add_answer("sacrifice")
                end
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I,\" he gasps, \"am called Caine. But I have also been given an alias by my... fellow townspeople. To them, I am known as `the Tortured One.'\" He moves his hands in a sweeping gesture, but seems to indicate nothing. \"And thou canst see why.\"")
                if not get_flag(380) and not get_flag(406) and not var_0002 then
                    add_answer("questions")
                end
                remove_answer("name")
                add_answer("why?")
                if not var_0001 and not get_flag(447) and not get_flag(448) then
                    add_answer("need formula")
                end
            elseif answer == "why?" then
                add_dialogue("\"The flames, fool! The flames!\" Again he gasps.")
                remove_answer("why?")
            elseif answer == "job" then
                add_dialogue("He smirks at your comment.")
                add_dialogue("\"Thou wishest to know my job? I will tell thee my job!\" he shouts.")
                add_dialogue("\"To burn here in eternal flames for my crime against the fair city of Skara Brae! That,\" he pauses for emphasis, \"is my job!\"")
                add_dialogue("After a moment, he calms down.")
                add_dialogue("\"I apologize, " .. var_0003 .. ". I realize thy question was not intended to further torment me,\" he sighs, and turns his face away from you. \"At one time, I was the alchemist here.\"")
                add_answer({"Skara Brae", "flames"})
                if not var_0001 and not get_flag(447) and not get_flag(448) then
                    add_answer("need formula")
                end
            elseif answer == "flames" then
                add_dialogue("He looks down at the ground, a remorseful expression on his face.")
                add_dialogue("\"The flames are my punishment. Years ago, when the evil Liche first exerted his reign of death over Skara Brae, the healer, Mordra, conceived of a plan to remove the creature most foul.\"")
                add_dialogue("\"She designed a concoction that would destroy the magical bonds that form the Liche. The formula was presented to our mayor, who passed it on to me.\"")
                add_dialogue("\"But,\" he scowls, \"something went wrong when I was preparing the potion. The proportions were mixed improperly, or... I don't know!\" he shouts, fists clenched.")
                add_dialogue("\"All I remember is the shop exploding, and the fire! The fire! All those people dead... because of me... because of my mistake....\"")
                remove_answer("flames")
                if not var_0000 then
                    add_answer("mayor")
                end
            elseif answer == "Skara Brae" then
                add_dialogue("\"'Twas a thriving town -- before I destroyed it!\" His jaw tightens and his face clenches. \"Why? Why, why, why!\" He again gasps in agony, but quickly regains control.")
                add_dialogue("\"There were so many innocent people,\" he says, staring directly at you. \"I cannot believe I am responsible for all their deaths.\"")
                add_answer("people")
                remove_answer("Skara Brae")
            elseif answer == "sacrifice" then
                add_dialogue("\"I am sorry, " .. var_0003 .. ", but I must spend my eternity here in constant memory of those whom I have destroyed.\"")
                set_flag(417, true)
                remove_answer("sacrifice")
            elseif answer == "mayor" or answer == "Forsythe" then
                add_dialogue("\"Forsythe is the mayor. Perhaps thou canst find him in the Town Hall, shouldst thou wish to speak with him.\"")
                var_0000 = true
                remove_answer({"mayor", "Forsythe"})
            elseif answer == "need formula" then
                add_dialogue("\"Thou trusts me to tell thee the formula! After what I have done to this town? Art thou mad? I hope at least, that thou hast checked with Mordra for the correct proportions, yes?\"")
                var_0004 = unknown_090AH()
                if var_0004 then
                    add_dialogue("He shakes his head in disbelief.")
                    add_dialogue("\"Thou art truly insane. But,\" he shrugs, \"thou hast nothing to lose but thine own life....\"")
                    add_answer("instructions")
                    set_flag(447, true)
                else
                    add_dialogue("\"That is better. Thou hadst me wondering.\" His tone is a mixture of both relief and disappointment.")
                end
                remove_answer("need formula")
            elseif answer == "instructions" then
                add_dialogue("\"First thou wilt need the three potions. Then, thou must place each one just below a connecting tube -- the order matters not. Take an empty vial -- I should have one here in my lab -- and set it below the nozzle. Then, turn on the burner. After but a few minutes, the mixture will form, and the filled vial will be ready for thee.\"")
                remove_answer("instructions")
            elseif answer == "people" then
                add_dialogue("\"Thou wishest to know whom I killed? I can only assume that all perished in the blaze: Markham and his Barmaid, Paulette; Trent and Forsythe; and, of course, Mordra the healer.\"")
                add_answer("Trent")
                if not var_0000 then
                    add_answer("Forsythe")
                end
                remove_answer("people")
            elseif answer == "Trent" then
                add_dialogue("\"He is -- was -- the blacksmith. Mine one consolation lay with him, for I thought there would be at least one advantage to his death. Sadly,\" he inhales quickly, \"even that did not occur.\"")
                add_answer({"advantage", "blacksmith"})
                remove_answer("Trent")
            elseif answer == "blacksmith" then
                add_dialogue("\"He was once a master of all things metal. Now all he does, so I am told, is work endlessly on that blasted cage!\"")
                remove_answer("blacksmith")
                add_answer("cage")
            elseif answer == "cage" then
                add_dialogue("\"I know nothing about it other than that it was necessary to put the liche in it before my... potion could work on him.\"")
                remove_answer("cage")
            elseif answer == "advantage" then
                add_dialogue("\"The liche took from Trent the one most valuable thing in the blacksmith's life -- his wife, Rowena. I had hoped his death would at least extinguish his pain.\" He smiles sardonically.")
                add_dialogue("\"Well, it did end his pain, in a manner of speaking.\"")
                remove_answer("advantage")
                add_answer({"end", "Rowena"})
            elseif answer == "end" then
                add_dialogue("\"The pain is gone, but only to be replaced by his obsessive anger. The poor fool does not even realize he is dead! He thrives on his anger.\"")
                remove_answer("end")
            elseif answer == "Rowena" then
                add_dialogue("\"She was all he lived for. When the liche tried to take her from him, he was consumed by the emptiness of her death. But, after his own demise,\" he stares directly at you, \"his bitter feelings soured even further.\"")
                add_dialogue("\"I suspect there is no reasoning with him now.\"")
                remove_answer("Rowena")
                add_answer("reasoning")
            elseif answer == "reasoning" then
                add_dialogue("\"I doubt he would believe even his own death, let alone care.\"")
                remove_answer("reasoning")
            elseif answer == "questions" then
                if not get_flag(444) then
                    add_dialogue("The ghost looks at you with a hint of amusement. \"Thou art looking for the answers to the questions of life and death?\"")
                    if unknown_090AH() then
                        add_dialogue("The Tortured One looks hard at you. After a pause, he speaks. \"I will tell thee what I know if thou dost agree to help me. Free me. Free all of us. Free us from the evil Liche.\"")
                        add_answer("Liche")
                        remove_answer("questions")
                    else
                        add_dialogue("\"Then I have no answers for thee.\"")
                        return
                    end
                elseif not get_flag(426) then
                    add_dialogue("\"Thou hast freed us from the Liche. Thou art entitled to mine half of the bargain.\"")
                    add_dialogue("\"So thou dost want to know the answers to the questions of life and death?\"")
                    if unknown_090AH() then
                        add_dialogue("The Tortured One looks hard at you. Then, smiling, he shakes his head. \"I have no secrets, my foolish friend. Thou art a fool. There are -no- answers. Only questions.\"")
                        add_dialogue("He looks as if he might cry out in pain. And then Caine turns away from you. \"Go away now. Leave me to mine eternity.\"")
                        set_flag(406, true)
                        unknown_0911H(700)
                        return
                    else
                        add_dialogue("\"Then why hast thou wasted thy time? Go away, fool!\"")
                        return
                    end
                else
                    add_dialogue("\"Thou hast not rid us of the evil Liche yet. Fulfill this quest as thou hast agreed and I shall give thee the answers thou dost seek.\"")
                end
                remove_answer("questions")
            elseif answer == "Liche" then
                add_dialogue("\"He is an evil spirit who inhabits poor dead Horance's body. He has a hold on every being in this town -- even me. He sucks the life forces -- the little that remain -- from our souls. Please, thou must free us from his power. Wilt thou try?\"")
                if unknown_090AH() then
                    add_dialogue("The Tortured One's eyes brighten somewhat, as he sees the light at the end of a long, dark tunnel. \"Then thou hast given me hope. To begin, speak with Mistress Mordra. She can tell thee how to accomplish this feat.\"")
                    remove_answer("Liche")
                    set_flag(444, true)
                else
                    add_dialogue("\"Then thou shalt never know the answers to the questions of life and death. An eye for an eye, my friend.\"")
                    return
                end
                remove_answer("Liche")
            elseif answer == "bye" then
                add_dialogue("\"Goodbye, " .. var_0003 .. ".\" He suppresses a pained scream as you depart.")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end