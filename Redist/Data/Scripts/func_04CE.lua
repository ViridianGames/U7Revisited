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
        bark(206, local4)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(206, 0)
    local0 = call_0909H()
    local1 = callis_001C(callis_001B(-206))
    add_answer({"bye", "job", "name"})

    if not get_flag(0x028B) then
        add_dialogue("A very neat, well-groomed, kindly man stands before you.")
        set_flag(0x028B, true)
    else
        add_dialogue("\"Greetings, ", local0, ". How may I help thee?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("He smiles at you. \"Ah, excellent. Thou art not afraid to ask question. Remember, there are no stupid questions, only dumb ones. My name is Eldroth, ", local0, ".\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I, my friend, am the provisioner. And, if I may be immodest, also a counselor for Vesper. Perhaps I can someday give thee advice, ", local0, ". For remember, that which does not kill us, makes us wounded.\"")
            add_answer({"buy", "Vesper"})
        elseif answer == "Vesper" then
            add_dialogue("\"Yes, ", local0, ", this town is full of wonderful people to whom I have given advice.\"")
            add_answer({"advice", "people"})
            remove_answer("Vesper")
        elseif answer == "advice" then
            add_dialogue("\"Early to bed, early to rise, makes Jack a dull boy.\"")
            remove_answer("advice")
        elseif answer == "buy" then
            if local1 == 7 then
                add_dialogue("\"Thou wishest to make a purchase. Excellent. But remember, a gold piece saved is a gold piece not spent.\"")
                call_087AH()
            else
                add_dialogue("\"Perhaps thou couldst wait until my shop is open, ", local0, ".\"")
            end
            remove_answer("buy")
        elseif answer == "people" then
            add_dialogue("\"About whom doth thou wish to know? Auston? The gargoyles? Liana? Cador? Perhaps Yongi?\"")
            _SaveAnswers()
            add_answer({"no one", "Cador", "Yongi", "Liana", "gargoyles", "Auston"})
            remove_answer("people")
        elseif answer == "no one" then
            _RestoreAnswers()
            remove_answer("no one")
        elseif answer == "Liana" then
            add_dialogue("\"Liana is a very fine young woman who clerks at the townhall.\"")
            remove_answer("Liana")
        elseif answer == "Yongi" then
            add_dialogue("\"He is the bartender at the Glided Gizzard.\" He stops, shakes his head, and then corrects himself. \"I mean the Lilded Lizard,\" he frowns. \"No, that's the Gilded Lizard. Yes that's it!\"")
            remove_answer("Yongi")
        elseif answer == "Cador" then
            add_dialogue("\"Cador oversees the mines. He and his wife, Yvella, have a lovely daughter named Catherine.\"")
            remove_answer("Cador")
        elseif answer == "Auston" then
            add_dialogue("\"The mayor? I would have thought thou wouldst have met him by now, ", local0, ". He is performing an excellent job. Thou mayest not realize this,\" he blushes, \"but 'tis I who suggested he run for the office.\"")
            remove_answer("Auston")
        elseif answer == "gargoyles" then
            add_dialogue("\"I fear they will stage an uprising. I know Auston holds the same thoughts, for very recently he approached me and asked for my guidance to prepare for just such an incident. I will warn thee just as I warned him. Always remember, ", local0, ", the best defense is a good defense!\"")
            remove_answer("gargoyles")
        elseif answer == "bye" then
            add_dialogue("\"Farewell, ", local0, ". Never forget, the grass is always greener when it rains.\"")
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