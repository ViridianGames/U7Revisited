--- Best guess: Manages Eldroth’s dialogue in Vesper, a provisioner and counselor offering quirky advice and insights on town residents.
function func_04CE(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        switch_talk_to(0, 206)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_001CH(get_npc_name(206))
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(651) then
            add_dialogue("A very neat, well-groomed, kindly man stands before you.")
            set_flag(651, true)
        else
            add_dialogue("\"Greetings, \" .. var_0000 .. \". How may I help thee?\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("He smiles at you. \"Ah, excellent. Thou art not afraid to ask question. Remember, there are no stupid questions, only dumb ones. My name is Eldroth, \" .. var_0000 .. \".\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I, my friend, am the provisioner. And, if I may be immodest, also a counselor for Vesper. Perhaps I can someday give thee advice, \" .. var_0000 .. \". For remember, that which does not kill us, makes us wounded.\"")
                add_answer({"buy", "Vesper"})
            elseif answer == "buy" then
                remove_answer("buy")
                if var_0001 == 7 then
                    add_dialogue("\"Thou wishest to make a purchase. Excellent. But remember, a gold piece saved is a gold piece not spent.\"")
                    unknown_087AH()
                else
                    add_dialogue("\"Perhaps thou couldst wait until my shop is open, \" .. var_0000 .. \".\"")
                end
            elseif answer == "Vesper" then
                add_dialogue("\"Yes, \" .. var_0000 .. \", this town is full of wonderful people to whom I have given advice.\"")
                add_answer({"advice", "people"})
                remove_answer("Vesper")
            elseif answer == "advice" then
                add_dialogue("\"Early to bed, early to rise, makes Jack a dull boy.\"")
                remove_answer("advice")
            elseif answer == "people" then
                add_dialogue("\"About whom doth thou wish to know? Auston? The gargoyles? Liana? Cador? Perhaps Yongi?\"")
                save_answers()
                add_answer({"no one", "Cador", "Yongi", "Liana", "gargoyles", "Auston"})
                remove_answer("people")
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
                add_dialogue("\"The mayor? I would have thought thou wouldst have met him by now, \" .. var_0000 .. \". He is performing an excellent job. Thou mayest not realize this,\" he blushes, \"but 'tis I who suggested he run for the office.\"")
                remove_answer("Auston")
            elseif answer == "gargoyles" then
                add_dialogue("\"I fear they will stage an uprising. I know Auston holds the same thoughts, for very recently he approached me and asked for my guidance to prepare for just such an incident. I will warn thee just as I warned him. Always remember, \" .. var_0000 .. \", the best defense is a good defense!\"")
                remove_answer("gargoyles")
            elseif answer == "no one" then
                restore_answers()
                remove_answer("people")
            elseif answer == "bye" then
                add_dialogue("\"Farewell, \" .. var_0000 .. \". Never forget, the grass is always greener when it rains.\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0002 = get_schedule()
        var_0001 = unknown_001CH(get_npc_name(206))
        var_0003 = random(4, 1)
        if var_0002 >= 2 and var_0002 <= 6 and (var_0001 == 7 or var_0001 == 5) then
            if var_0003 == 1 then
                var_0004 = "@A stitch in time uses more thread.@"
            elseif var_0003 == 2 then
                var_0004 = "@Never hit a man when thou cannot.@"
            elseif var_0003 == 3 then
                var_0004 = "@The early bird wakes up first.@"
            elseif var_0004 == 4 then
                var_0004 = "@A bird in the hand squirms.@"
            end
            bark(var_0004, 206)
        end
    end
    return
end