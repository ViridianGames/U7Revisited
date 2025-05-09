--- Best guess: Manages Lap-Lem’s dialogue in Vesper, a gargoyle miner facing racial tensions and seeking the return of a stolen amulet.
function func_04D3(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 211)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(656) then
            add_dialogue("You are greeted with a smile from this gargoyle.")
            set_flag(656, true)
        else
            add_dialogue("\"To be pleased to again see you, human.\" Lap-Lem smiles.")
        end
        var_0000 = unknown_0931H(3, 359, 955, 1, 357)
        if get_flag(641) or var_0000 then
            if not get_flag(735) then
                add_answer("give amulet")
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be known to you as Lap-Lem.\"")
                add_answer("Lap-Lem")
                remove_answer("name")
                if get_flag(640) and not get_flag(735) then
                    add_answer("Blorn")
                end
            elseif answer == "Lap-Lem" then
                add_dialogue("\"To mean `rock one.'\"")
                remove_answer("Lap-Lem")
            elseif answer == "job" then
                add_dialogue("\"To be a miner. To be now the only miner of my race in this town.\"")
                add_answer({"town", "race", "only miner"})
            elseif answer == "race" then
                add_dialogue("\"To know of many gargoyles who work in the other mines, but to see the Vesper mine has only humans now.\"")
                remove_answer("race")
            elseif answer == "town" then
                add_dialogue("\"To be called Vesper. To be the only place, other than parts of Britain, where gargoyles live with humans. To tell you that here are more conflicts.\" He sighs.")
                add_dialogue("\"To wonder if Terfin would be a better choice to maintain a home.\"")
                remove_answer("town")
                add_answer({"Terfin", "conflicts"})
            elseif answer == "conflicts" then
                add_dialogue("\"To see the humans grow in hostility to us. Sadly, to also see many gargoyles begin to show mutual feelings. To hope the situation never becomes violent.\"")
                remove_answer("conflicts")
            elseif answer == "Terfin" then
                add_dialogue("\"To be the gargoyle home city. To have been constructed two hundred years ago when the codex was placed in the void and the gargoyles were without places to live. Though not prohibited, no humans reside there.\"")
                remove_answer("Terfin")
            elseif answer == "only miner" then
                add_dialogue("\"To tell you that there was another -- Anmanivas. To have left because of racial hatred. To sit now in tavern all day with brother, Foranamo. To feel bad for Anmanivas and brother, but to need job.\" He shrugs.")
                add_dialogue("\"To put up with hatred.\"")
                remove_answer("only miner")
            elseif answer == "Blorn" then
                add_dialogue("\"To know of incident?\"")
                var_0001 = unknown_090AH()
                if not var_0001 then
                    add_dialogue("\"To be very sorry for attack, but was in defense of possession.\" He lowers his head as if ashamed.")
                else
                    add_dialogue("\"To be ashamed. To want nothing more than return of my possession from human.\"")
                end
                add_answer("possession")
                remove_answer("Blorn")
            elseif answer == "possession" then
                add_dialogue("\"To have had an amulet with sentimental value. To have been stolen by the human.\" He looks down at his feet. \"To want it back.\"")
                remove_answer("possession")
                set_flag(642, true)
            elseif answer == "give amulet" then
                add_dialogue("\"To have returned with amulet?\"")
                var_0002 = unknown_002BH(false, 3, 359, 955, 1)
                if var_0002 then
                    unknown_0911H(50)
                    add_dialogue("He grins widely as you return the jewelry to him.")
                    add_dialogue("\"To thank you, human! To be an example for your race!\"")
                    set_flag(735, true)
                else
                    add_dialogue("\"Oh. To not have amulet with you.\" He perks up and smiles. \"To return later with amulet!\"")
                end
                remove_answer("give amulet")
            elseif answer == "bye" then
                add_dialogue("\"To hope to see you again soon.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092FH(211)
    end
    return
end