-- Function 04F7: Caine's tormented dialogue and Skara Brae's tragic past
function func_04F7(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(247, 0)
    if not get_flag(0x01B2) then
        add_dialogue("The non-corporeal man stares past you, seemingly past the confines of the building, and, perhaps, of the world. Then, he suddenly shudders, as if he is filled with pain.*")
        return
    end

    local0 = false
    local1 = false
    local2 = false
    local3 = call_0909H()
    add_answer({"bye", "job", "name"})

    if not get_flag(0x01C2) then
        add_dialogue("The ghostly man displays a face filled with pain.")
        set_flag(0x01C2, true)
    else
        add_dialogue("\"Greetings, ", local3, ".\" Caine breathes deeply, apparently forcing back his torment.")
        if not get_flag(0x017C) and not get_flag(0x0196) then
            add_answer("questions")
            local2 = true
        end
        if not get_flag(0x01BF) and not get_flag(0x01C0) then
            add_answer("need formula")
            local1 = true
        end
    end

    if not get_flag(0x01BF) and not get_flag(0x01D0) then
        add_answer("instructions")
    end
    if not get_flag(0x0198) and not get_flag(0x01A1) then
        add_answer("sacrifice")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I,\" he gasps, \"am called Caine. But I have also been given an alias by my... fellow townspeople. To them, I am known as 'the Tortured One.'\" He moves his hands in a sweeping gesture, but seems to indicate nothing. \"And thou canst see why.\"")
            if not get_flag(0x017C) and not get_flag(0x0196) and not local2 then
                add_answer("questions")
            end
            remove_answer("name")
            add_answer("why?")
            if not local1 and not get_flag(0x01BF) and not get_flag(0x01C0) then
                add_answer("need formula")
            end
        elseif answer == "why?" then
            add_dialogue("\"The flames, fool! The flames!\" Again he gasps.")
            remove_answer("why?")
        elseif answer == "job" then
            add_dialogue("He smirks at your comment.~~\"Thou wishest to know my job? I will tell thee my job!\" he shouts.~\"To burn here in eternal flames for my crime against the fair city of Skara Brae! That,\" he pauses for emphasis, \"is my job!\"~After a moment, he calms down.~\"I apologize, ", local3, ". I realize thy question was not intended to further torment me,\" he sighs, and turns his face away from you. \"At one time, I was the alchemist here.\"")
            add_answer({"Skara Brae", "flames"})
            if not local1 and not get_flag(0x01BF) and not get_flag(0x01C0) then
                add_answer("need formula")
            end
        elseif answer == "flames" then
            add_dialogue("He looks down at the ground, a remorseful expression on his face.~~\"The flames are my punishment. Years ago, when the evil Liche first exerted his reign of death over Skara Brae, the healer, Mordra, conceived of a plan to remove the creature most foul.~~\"She designed a concoction that would destroy the magical bonds that form the Liche. The formula was presented to our mayor, who passed it on to me.~~\"But,\" he scowls, \"something went wrong when I was preparing the potion. The proportions were mixed improperly, or... I don't know!\" he shouts, fists clenched.~~\"All I remember is the shop exploding, and the fire! The fire! All those people dead... because of me... because of my mistake....\"")
            remove_answer("flames")
            if not local0 then
                add_answer("mayor")
            end
        elseif answer == "Skara Brae" then
            add_dialogue("\"'Twas a thriving town -- before I destroyed it!\" His jaw tightens and his face clenches. \"Why? Why, why, why!\" He again gasps in agony, but quickly regains control.~~\"There were so many innocent people,\" he says, staring directly at you. \"I cannot believe I am responsible for all their deaths.\"")
            add_answer("people")
            remove_answer("Skara Brae")
        elseif answer == "sacrifice" then
            add_dialogue("\"I am sorry, ", local3, ", but I must spend my eternity here in constant memory of those whom I have destroyed.\"")
            set_flag(0x01A1, true)
            remove_answer("sacrifice")
        elseif answer == "mayor" then
            add_dialogue("\"Forsythe is the mayor. Perhaps thou canst find him in the Town Hall, shouldst thou wish to speak with him.\"")
            local0 = true
            remove_answer({"mayor", "Forsythe"})
        elseif answer == "need formula" then
            add_dialogue("\"Thou trusts me to tell thee the formula! After what I have done to this town? Art thou mad? I hope at least, that thou hast checked with Mordra for the correct proportions, yes?\"")
            local4 = call_090AH()
            if local4 then
                add_dialogue("He shakes his head in disbelief.~~\"Thou art truly insane. But,\" he shrugs, \"thou hast nothing to lose but thine own life....\"")
                add_answer("instructions")
                set_flag(0x01BF, true)
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
            if not local0 then
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
            add_dialogue("\"The liche took from Trent the one most valuable thing in the blacksmith's life -- his wife, Rowena. I had hoped his death would at least extinguish his pain.\" He smiles sardonically.~~\"Well, it did end his pain, in a manner of speaking.\"")
            remove_answer("advantage")
            add_answer({"end", "Rowena"})
        elseif answer == "end" then
            add_dialogue("\"The pain is gone, but only to be replaced by his obsessive anger. The poor fool does not even realize he is dead! He thrives on his anger.\"")
            remove_answer("end")
        elseif answer == "Rowena" then
            add_dialogue("\"She was all he lived for. When the liche tried to take her from him, he was consumed by the emptiness of her death. But, after his own demise,\" he stares directly at you, \"his bitter feelings soured even further.~~\"I suspect there is no reasoning with him now.\"")
            remove_answer("Rowena")
            add_answer("reasoning")
        elseif answer == "reasoning" then
            add_dialogue("\"I doubt he would believe even his own death, let alone care.\"")
            remove_answer("reasoning")
        elseif answer == "questions" then
            if not get_flag(0x01BC) then
                add_dialogue("The ghost looks at you with a hint of amusement. \"Thou art looking for the answers to the questions of life and death?\"")
                local4 = call_090AH()
                if local4 then
                    add_dialogue("The Tortured One looks hard at you. After a pause, he speaks. \"I will tell thee what I know if thou dost agree to help me. Free me. Free all of us. Free us from the evil Liche.\"")
                    add_answer("Liche")
                    remove_answer("questions")
                else
                    add_dialogue("\"Then I have no answers for thee.\"*")
                    return
                end
            elseif not get_flag(0x01AA) then
                add_dialogue("\"Thou hast freed us from the Liche. Thou art entitled to mine half of the bargain.~~\"So thou dost want to know the answers to the questions of life and death?\"")
                local4 = call_090AH()
                if local4 then
                    add_dialogue("The Tortured One looks hard at you. Then, smiling, he shakes his head. \"I have no secrets, my foolish friend. Thou art a fool. There are -no- answers. Only questions.\"~~He looks as if he might cry out in pain. And then Caine turns away from you. \"Go away now. Leave me to mine eternity.\"*")
                    set_flag(0x0196, true)
                    call_0911H(700)
                    return
                else
                    add_dialogue("\"Then why hast thou wasted thy time? Go away, fool!\"*")
                    return
                end
            else
                add_dialogue("\"Thou hast not rid us of the evil Liche yet. Fulfill this quest as thou hast agreed and I shall give thee the answers thou dost seek.\"")
                remove_answer("questions")
            end
        elseif answer == "Liche" then
            add_dialogue("\"He is an evil spirit who inhabits poor dead Horance's body. He has a hold on every being in this town -- even me. He sucks the life forces -- the little that remain -- from our souls. Please, thou must free us from his power. Wilt thou try?\"")
            local4 = call_090AH()
            if local4 then
                add_dialogue("The Tortured One's eyes brighten somewhat, as he sees the light at the end of a long, dark tunnel. \"Then thou hast given me hope. To begin, speak with Mistress Mordra. She can tell thee how to accomplish this feat.\"")
                remove_answer("Liche")
                set_flag(0x01BC, true)
            else
                add_dialogue("\"Then thou shalt never know the answers to the questions of life and death. An eye for an eye, my friend.\"*")
                return
            end
            remove_answer("Liche")
        elseif answer == "bye" then
            add_dialogue("\"Goodbye, ", local3, ".\" He suppresses a pained scream as you depart.*")
            return
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end