--- Best guess: Manages Sir Horffe's dialogue in Serpent's Hold, a gargoyle captain revealing he was wounded trying to stop the statue vandal.
function npc_sir_horffe_0197(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 197)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(606) and not get_flag(613) then
            add_answer("statue")
        end
        if get_flag(630) and not get_flag(609) then
            add_answer("Pendaran did it")
        end
        if not get_flag(622) then
            var_0000 = get_distance(-195, -197)
            if var_0000 < 11 then
                if not get_flag(620) then
                    var_0001 = " standing at attention just behind Lord John-Paul."
                else
                    var_0001 = " standing at attention just behind another knight."
                end
            else
                var_0001 = "."
            end
            add_dialogue("You see a gargoyle with a very stern expression on his face" .. var_0001)
            var_0002 = npc_id_in_party(-195)
            set_flag(622, true)
        else
            add_dialogue("\"To ask how to be of assistance.\" His eyes narrow.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be named Horffe.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"To be the Captain of the guard. To serve and protect the people of Serpent's Hold.\"")
                add_answer({"Serpent's Hold", "Captain"})
            elseif answer == "Captain" then
                add_dialogue("\"To have been commanded to protect the people who live in Serpent's Hold and to maintain the general order of the knights.\"")
                remove_answer("Captain")
                add_answer({"knights", "people"})
            elseif answer == "people" or answer == "Serpent's Hold" then
                add_dialogue("\"To direct you to Sir Denton, the tavernkeeper at the Hallowed Dock. To know more about the Hold and the people than I.\"")
                remove_answer({"Serpent's Hold", "people"})
            elseif answer == "Pendaran did it" then
                add_dialogue("\"To thank you for this information. To be pleased to know the identity of my assailant.\"")
                remove_answer("Pendaran did it")
            elseif answer == "knights" then
                add_dialogue("\"To inform you that many fine warriors take up residence between the Hold's walls. To have little fear of an attack from bandits or vicious animals.\"")
                remove_answer("knights")
            elseif answer == "statue" then
                add_dialogue("\"To know nothing about that!\"")
                if get_flag(607) then
                    add_answer("blood on fragments")
                end
                remove_answer("statue")
            elseif answer == "blood on fragments" then
                add_dialogue("His rough demeanor softens.")
                add_dialogue("\"To be my blood.\" He sighs. \"But to be not the one who defaced the statue! To have been wounded while trying to stop the vandal.\"")
                add_answer("vandal")
                remove_answer("blood on fragments")
                set_flag(613, true)
            elseif answer == "vandal" then
                add_dialogue("He looks down at his feet.")
                add_dialogue("\"To know not who he was. To have been very dark. To ask you not to tell Sir Richter.\"")
                remove_answer("vandal")
                add_answer({"Sir Richter", "dark"})
            elseif answer == "dark" then
                add_dialogue("\"To have been very poor visibility, but to be positive I was scuffling with an armed knight.\"")
                remove_answer("dark")
            elseif answer == "Sir Richter" then
                add_dialogue("\"To know he will not believe one who openly defies The Fellowship.\"")
                remove_answer("Sir Richter")
                add_answer("Fellowship")
            elseif answer == "Fellowship" then
                add_dialogue("\"To know little about it. To like little about it.\"")
                remove_answer("Fellowship")
            elseif answer == "bye" then
                add_dialogue("\"To say goodbye.\"")
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1071(197)
    end
    return
end