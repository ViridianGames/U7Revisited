--- Best guess: Manages For-Lem’s dialogue in Vesper, a gargoyle laborer preserving gargoyle legends and concerned about a human girl, Catherine.
function func_04D6(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        switch_talk_to(0, 214)
        start_conversation()
        add_answer({"bye", "job", "name"})
        var_0000 = unknown_08F7H(213)
        if var_0000 then
            add_answer("girl")
        end
        if not get_flag(659) then
            add_dialogue("You see a very large, strong wingless gargoyle.")
            set_flag(659, true)
        else
            add_dialogue("\"To wish you good day, human,\" says For-Lem.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To answer to For-Lem.\"")
                remove_answer("name")
                add_answer("For-Lem")
            elseif answer == "For-Lem" then
                add_dialogue("\"To mean `strong one.'\"")
                remove_answer("For-Lem")
            elseif answer == "job" then
                add_dialogue("\"To do odd jobs for others. Also, to record gargoyle legends in written form.\"")
                add_answer({"legends", "others"})
            elseif answer == "others" then
                add_dialogue("\"To be friends with Lap-Lem, and know he is a good miner. Also to know Ansikart, who reminds us of Singularity in these troubled times.\"")
                add_answer("troubled times")
                remove_answer("others")
            elseif answer == "troubled times" then
                add_dialogue("\"To be angry with the humans. To be treated poorly and with contempt. To know not why,\" he shrugs.")
                remove_answer("troubled times")
            elseif answer == "legends" then
                add_dialogue("\"To have many interesting stories about our race. To be writing them down for future generations.\"")
                remove_answer("legends")
                add_answer({"generations", "stories"})
            elseif answer == "stories" then
                add_dialogue("\"To have had many exciting myths from before the Avatar's encounters with our race. To share the concept of a hero with the humans, but to have had different heroes from our own history.\"")
                remove_answer("stories")
            elseif answer == "generations" then
                add_dialogue("\"To be afraid for the future of gargoyle youths. To tell you they know little about their heritage. To feel it important to educate them and the offspring who follow them in our ways and history.\"")
                remove_answer("generations")
            elseif answer == "girl" then
                add_dialogue("A look of concern quickly appears on his face.")
                add_dialogue("\"To talk about the human girl, Catherine? To mean no harm to her.\" He holds out his hands.")
                add_dialogue("\"To read gargoyle mythology to her during the day only. To have been asked by her!\" His eyes widen.")
                add_dialogue("\"To ask you not to tell her parents, for they will punish her.\" He looks hopeful. \"To tell not, agreed?\"")
                var_0001 = unknown_090AH()
                if var_0001 then
                    add_dialogue("\"To be making the right decision.\" He appears relieved. \"To thank you, human.\" He smiles.")
                else
                    add_dialogue("\"To be making a mistake.\" He appears disappointed. \"To have the girl punished now because of me.\" He shakes his head.")
                    add_dialogue("\"To feel responsible. To be very sad.\"")
                end
                unknown_0911H(50)
                set_flag(637, true)
                remove_answer("girl")
            elseif answer == "bye" then
                add_dialogue("\"To tell you goodbye, human.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092FH(214)
    end
    return
end