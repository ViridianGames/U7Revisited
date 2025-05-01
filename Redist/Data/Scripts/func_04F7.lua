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
        say("The non-corporeal man stares past you, seemingly past the confines of the building, and, perhaps, of the world. Then, he suddenly shudders, as if he is filled with pain.*")
        return
    end

    local0 = false
    local1 = false
    local2 = false
    local3 = call_0909H()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x01C2) then
        say("The ghostly man displays a face filled with pain.")
        set_flag(0x01C2, true)
    else
        say("\"Greetings, ", local3, ".\" Caine breathes deeply, apparently forcing back his torment.")
        if not get_flag(0x017C) and not get_flag(0x0196) then
            _AddAnswer("questions")
            local2 = true
        end
        if not get_flag(0x01BF) and not get_flag(0x01C0) then
            _AddAnswer("need formula")
            local1 = true
        end
    end

    if not get_flag(0x01BF) and not get_flag(0x01D0) then
        _AddAnswer("instructions")
    end
    if not get_flag(0x0198) and not get_flag(0x01A1) then
        _AddAnswer("sacrifice")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I,\" he gasps, \"am called Caine. But I have also been given an alias by my... fellow townspeople. To them, I am known as 'the Tortured One.'\" He moves his hands in a sweeping gesture, but seems to indicate nothing. \"And thou canst see why.\"")
            if not get_flag(0x017C) and not get_flag(0x0196) and not local2 then
                _AddAnswer("questions")
            end
            _RemoveAnswer("name")
            _AddAnswer("why?")
            if not local1 and not get_flag(0x01BF) and not get_flag(0x01C0) then
                _AddAnswer("need formula")
            end
        elseif answer == "why?" then
            say("\"The flames, fool! The flames!\" Again he gasps.")
            _RemoveAnswer("why?")
        elseif answer == "job" then
            say("He smirks at your comment.~~\"Thou wishest to know my job? I will tell thee my job!\" he shouts.~\"To burn here in eternal flames for my crime against the fair city of Skara Brae! That,\" he pauses for emphasis, \"is my job!\"~After a moment, he calms down.~\"I apologize, ", local3, ". I realize thy question was not intended to further torment me,\" he sighs, and turns his face away from you. \"At one time, I was the alchemist here.\"")
            _AddAnswer({"Skara Brae", "flames"})
            if not local1 and not get_flag(0x01BF) and not get_flag(0x01C0) then
                _AddAnswer("need formula")
            end
        elseif answer == "flames" then
            say("He looks down at the ground, a remorseful expression on his face.~~\"The flames are my punishment. Years ago, when the evil Liche first exerted his reign of death over Skara Brae, the healer, Mordra, conceived of a plan to remove the creature most foul.~~\"She designed a concoction that would destroy the magical bonds that form the Liche. The formula was presented to our mayor, who passed it on to me.~~\"But,\" he scowls, \"something went wrong when I was preparing the potion. The proportions were mixed improperly, or... I don't know!\" he shouts, fists clenched.~~\"All I remember is the shop exploding, and the fire! The fire! All those people dead... because of me... because of my mistake....\"")
            _RemoveAnswer("flames")
            if not local0 then
                _AddAnswer("mayor")
            end
        elseif answer == "Skara Brae" then
            say("\"'Twas a thriving town -- before I destroyed it!\" His jaw tightens and his face clenches. \"Why? Why, why, why!\" He again gasps in agony, but quickly regains control.~~\"There were so many innocent people,\" he says, staring directly at you. \"I cannot believe I am responsible for all their deaths.\"")
            _AddAnswer("people")
            _RemoveAnswer("Skara Brae")
        elseif answer == "sacrifice" then
            say("\"I am sorry, ", local3, ", but I must spend my eternity here in constant memory of those whom I have destroyed.\"")
            set_flag(0x01A1, true)
            _RemoveAnswer("sacrifice")
        elseif answer == "mayor" then
            say("\"Forsythe is the mayor. Perhaps thou canst find him in the Town Hall, shouldst thou wish to speak with him.\"")
            local0 = true
            _RemoveAnswer({"mayor", "Forsythe"})
        elseif answer == "need formula" then
            say("\"Thou trusts me to tell thee the formula! After what I have done to this town? Art thou mad? I hope at least, that thou hast checked with Mordra for the correct proportions, yes?\"")
            local4 = call_090AH()
            if local4 then
                say("He shakes his head in disbelief.~~\"Thou art truly insane. But,\" he shrugs, \"thou hast nothing to lose but thine own life....\"")
                _AddAnswer("instructions")
                set_flag(0x01BF, true)
            else
                say("\"That is better. Thou hadst me wondering.\" His tone is a mixture of both relief and disappointment.")
            end
            _RemoveAnswer("need formula")
        elseif answer == "instructions" then
            say("\"First thou wilt need the three potions. Then, thou must place each one just below a connecting tube -- the order matters not. Take an empty vial -- I should have one here in my lab -- and set it below the nozzle. Then, turn on the burner. After but a few minutes, the mixture will form, and the filled vial will be ready for thee.\"")
            _RemoveAnswer("instructions")
        elseif answer == "people" then
            say("\"Thou wishest to know whom I killed? I can only assume that all perished in the blaze: Markham and his Barmaid, Paulette; Trent and Forsythe; and, of course, Mordra the healer.\"")
            _AddAnswer("Trent")
            if not local0 then
                _AddAnswer("Forsythe")
            end
            _RemoveAnswer("people")
        elseif answer == "Trent" then
            say("\"He is -- was -- the blacksmith. Mine one consolation lay with him, for I thought there would be at least one advantage to his death. Sadly,\" he inhales quickly, \"even that did not occur.\"")
            _AddAnswer({"advantage", "blacksmith"})
            _RemoveAnswer("Trent")
        elseif answer == "blacksmith" then
            say("\"He was once a master of all things metal. Now all he does, so I am told, is work endlessly on that blasted cage!\"")
            _RemoveAnswer("blacksmith")
            _AddAnswer("cage")
        elseif answer == "cage" then
            say("\"I know nothing about it other than that it was necessary to put the liche in it before my... potion could work on him.\"")
            _RemoveAnswer("cage")
        elseif answer == "advantage" then
            say("\"The liche took from Trent the one most valuable thing in the blacksmith's life -- his wife, Rowena. I had hoped his death would at least extinguish his pain.\" He smiles sardonically.~~\"Well, it did end his pain, in a manner of speaking.\"")
            _RemoveAnswer("advantage")
            _AddAnswer({"end", "Rowena"})
        elseif answer == "end" then
            say("\"The pain is gone, but only to be replaced by his obsessive anger. The poor fool does not even realize he is dead! He thrives on his anger.\"")
            _RemoveAnswer("end")
        elseif answer == "Rowena" then
            say("\"She was all he lived for. When the liche tried to take her from him, he was consumed by the emptiness of her death. But, after his own demise,\" he stares directly at you, \"his bitter feelings soured even further.~~\"I suspect there is no reasoning with him now.\"")
            _RemoveAnswer("Rowena")
            _AddAnswer("reasoning")
        elseif answer == "reasoning" then
            say("\"I doubt he would believe even his own death, let alone care.\"")
            _RemoveAnswer("reasoning")
        elseif answer == "questions" then
            if not get_flag(0x01BC) then
                say("The ghost looks at you with a hint of amusement. \"Thou art looking for the answers to the questions of life and death?\"")
                local4 = call_090AH()
                if local4 then
                    say("The Tortured One looks hard at you. After a pause, he speaks. \"I will tell thee what I know if thou dost agree to help me. Free me. Free all of us. Free us from the evil Liche.\"")
                    _AddAnswer("Liche")
                    _RemoveAnswer("questions")
                else
                    say("\"Then I have no answers for thee.\"*")
                    return
                end
            elseif not get_flag(0x01AA) then
                say("\"Thou hast freed us from the Liche. Thou art entitled to mine half of the bargain.~~\"So thou dost want to know the answers to the questions of life and death?\"")
                local4 = call_090AH()
                if local4 then
                    say("The Tortured One looks hard at you. Then, smiling, he shakes his head. \"I have no secrets, my foolish friend. Thou art a fool. There are -no- answers. Only questions.\"~~He looks as if he might cry out in pain. And then Caine turns away from you. \"Go away now. Leave me to mine eternity.\"*")
                    set_flag(0x0196, true)
                    call_0911H(700)
                    return
                else
                    say("\"Then why hast thou wasted thy time? Go away, fool!\"*")
                    return
                end
            else
                say("\"Thou hast not rid us of the evil Liche yet. Fulfill this quest as thou hast agreed and I shall give thee the answers thou dost seek.\"")
                _RemoveAnswer("questions")
            end
        elseif answer == "Liche" then
            say("\"He is an evil spirit who inhabits poor dead Horance's body. He has a hold on every being in this town -- even me. He sucks the life forces -- the little that remain -- from our souls. Please, thou must free us from his power. Wilt thou try?\"")
            local4 = call_090AH()
            if local4 then
                say("The Tortured One's eyes brighten somewhat, as he sees the light at the end of a long, dark tunnel. \"Then thou hast given me hope. To begin, speak with Mistress Mordra. She can tell thee how to accomplish this feat.\"")
                _RemoveAnswer("Liche")
                set_flag(0x01BC, true)
            else
                say("\"Then thou shalt never know the answers to the questions of life and death. An eye for an eye, my friend.\"*")
                return
            end
            _RemoveAnswer("Liche")
        elseif answer == "bye" then
            say("\"Goodbye, ", local3, ".\" He suppresses a pained scream as you depart.*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
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