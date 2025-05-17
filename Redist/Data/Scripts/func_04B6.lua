--- Best guess: Manages Inmanilem’s dialogue in Terfin, a gargoyle healer providing information about the city and its residents.
function func_04B6(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        switch_talk_to(0, 182)
        var_0000 = 182
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(583) then
            add_dialogue("You are greeted by a friendly gargoyle.")
            set_flag(583, true)
        else
            add_dialogue("\"To see you are doing well, human,\" says Inmanilem.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be called Inmanilem, human. To wish information about Terfin?\"")
                remove_answer("name")
                add_answer({"Inmanilem", "information"})
            elseif answer == "Inmanilem" then
                add_dialogue("\"To be Gargoyle for `make healed one.'\"")
                remove_answer("Inmanilem")
            elseif answer == "job" then
                add_dialogue("\"To be the healer.\"")
                add_answer("heal")
                if get_flag(580) then
                    add_answer("conflicts")
                end
            elseif answer == "heal" then
                var_0001 = get_schedule()
                if var_0001 == 2 or var_0001 == 3 or var_0001 == 4 or var_0001 == 5 then
                    unknown_089DH(430, 10, 25)
                else
                    add_dialogue("\"To feel sorry, but to be busy with other things now. To ask you to come back when I have the time to heal you.\"")
                end
                remove_answer("Heal")
            elseif answer == "information" then
                add_dialogue("\"To tell you to seek out Draxinusom, human, or Forbrak. To have much information about Terfin.\"")
                remove_answer("information")
                add_answer({"Terfin", "Forbrak", "Draxinusom"})
            elseif answer == "Forbrak" then
                add_dialogue("\"To be the tavernkeeper. To be very strong of body, and of mind.\"")
                remove_answer("Forbrak")
            elseif answer == "Terfin" then
                add_dialogue("\"To be the city of gargoyles. To be the one of two towns where many gargoyles live. To like it here,\" he adds, smiling.")
                remove_answer("Terfin")
                add_answer("one?")
            elseif answer == "one?" then
                add_dialogue("\"To tell you the other is called Vesper. To be in the desert in northeastern Britannia. To have also humans living there, unlike here.\"")
                remove_answer("one?")
            elseif answer == "Draxinusom" then
                add_dialogue("\"To be our leader. To live near the Hall of Knowledge.\"")
                remove_answer("Draxinusom")
                add_answer("Hall")
            elseif answer == "Hall" then
                add_dialogue("\"To be where the three altars of singularity are kept.\"")
                remove_answer("Hall")
                add_answer("altars")
            elseif answer == "altars" then
                add_dialogue("\"To be Passion, Control, and Diligence. To be the values that most gargoyles hold as the key of our existence.\"")
                remove_answer("altars")
                add_answer({"key", "most gargoyles"})
            elseif answer == "key" then
                add_dialogue("He nods his head emphatically. \"To be quite similar to the human concept of virtues.\"")
                remove_answer("key")
            elseif answer == "most gargoyles" then
                add_dialogue("\"There is a rival now -- The Fellowship. To know not if it is good or bad, but to know I do not follow it!\"")
                remove_answer("most gargoyles")
            elseif answer == "conflicts" then
                add_dialogue("\"To know only of one dissatisfied gargoyle. To have always been problem, but now acting hostile and aggressive. To be named Silamo, the gardener.\"")
                add_dialogue("\"To recommend you talk to Silamo.\"")
                remove_answer("conflicts")
                set_flag(573, true)
            elseif answer == "bye" then
                add_dialogue("\"To wish you good health, human.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092FH(182)
    end
    return
end