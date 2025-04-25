-- Function 04CE: Eldroth's provisioner dialogue and quirky advice
function func_04CE(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        local2 = callis_003B()
        local1 = callis_001C(callis_001B(-206))
        local3 = callis_Random2(4, 1)
        local4 = ""
        if local2 >= 2 and local2 <= 6 and (local1 == 7 or local1 == 5) then
            if local3 == 1 then
                local4 = "A stitch in time uses more thread."
            elseif local3 == 2 then
                local4 = "Never hit a man when thou cannot."
            elseif local3 == 3 then
                local4 = "The early bird wakes up first."
            elseif local3 == 4 then
                local4 = "A bird in the hand squirms."
            end
        end
        _ItemSay(local4, -206)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -206)
    local0 = call_0909H()
    local1 = callis_001C(callis_001B(-206))
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x028B) then
        say("A very neat, well-groomed, kindly man stands before you.")
        set_flag(0x028B, true)
    else
        say("\"Greetings, ", local0, ". How may I help thee?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("He smiles at you. \"Ah, excellent. Thou art not afraid to ask question. Remember, there are no stupid questions, only dumb ones. My name is Eldroth, ", local0, ".\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I, my friend, am the provisioner. And, if I may be immodest, also a counselor for Vesper. Perhaps I can someday give thee advice, ", local0, ". For remember, that which does not kill us, makes us wounded.\"")
            _AddAnswer({"buy", "Vesper"})
        elseif answer == "Vesper" then
            say("\"Yes, ", local0, ", this town is full of wonderful people to whom I have given advice.\"")
            _AddAnswer({"advice", "people"})
            _RemoveAnswer("Vesper")
        elseif answer == "advice" then
            say("\"Early to bed, early to rise, makes Jack a dull boy.\"")
            _RemoveAnswer("advice")
        elseif answer == "buy" then
            if local1 == 7 then
                say("\"Thou wishest to make a purchase. Excellent. But remember, a gold piece saved is a gold piece not spent.\"")
                call_087AH()
            else
                say("\"Perhaps thou couldst wait until my shop is open, ", local0, ".\"")
            end
            _RemoveAnswer("buy")
        elseif answer == "people" then
            say("\"About whom doth thou wish to know? Auston? The gargoyles? Liana? Cador? Perhaps Yongi?\"")
            _SaveAnswers()
            _AddAnswer({"no one", "Cador", "Yongi", "Liana", "gargoyles", "Auston"})
            _RemoveAnswer("people")
        elseif answer == "no one" then
            _RestoreAnswers()
            _RemoveAnswer("no one")
        elseif answer == "Liana" then
            say("\"Liana is a very fine young woman who clerks at the townhall.\"")
            _RemoveAnswer("Liana")
        elseif answer == "Yongi" then
            say("\"He is the bartender at the Glided Gizzard.\" He stops, shakes his head, and then corrects himself. \"I mean the Lilded Lizard,\" he frowns. \"No, that's the Gilded Lizard. Yes that's it!\"")
            _RemoveAnswer("Yongi")
        elseif answer == "Cador" then
            say("\"Cador oversees the mines. He and his wife, Yvella, have a lovely daughter named Catherine.\"")
            _RemoveAnswer("Cador")
        elseif answer == "Auston" then
            say("\"The mayor? I would have thought thou wouldst have met him by now, ", local0, ". He is performing an excellent job. Thou mayest not realize this,\" he blushes, \"but 'tis I who suggested he run for the office.\"")
            _RemoveAnswer("Auston")
        elseif answer == "gargoyles" then
            say("\"I fear they will stage an uprising. I know Auston holds the same thoughts, for very recently he approached me and asked for my guidance to prepare for just such an incident. I will warn thee just as I warned him. Always remember, ", local0, ", the best defense is a good defense!\"")
            _RemoveAnswer("gargoyles")
        elseif answer == "bye" then
            say("\"Farewell, ", local0, ". Never forget, the grass is always greener when it rains.\"")
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