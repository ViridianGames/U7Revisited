--- Best guess: Handles dialogue with Chantu, the Trinsic healer, discussing his services, the Fellowship, and the local murder, with healing options.
function func_0411(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        switch_talk_to(17, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_0067H() --- Guess: Checks Fellowship membership
        add_answer({"bye", "services", "murder", "job", "name"})
        if not get_flag(63) then
            add_answer({"Klog", "Fellowship"})
        end
        if not get_flag(82) then
            add_dialogue("You see a solemn fellow in healer's robes.")
            set_flag(82, true)
        else
            add_dialogue("\"Hello, again,\" Chantu says. \"How may I help thee?\"")
        end
        while true do
            var_0002 = get_answer()
            if var_0002 == "name" then
                add_dialogue("\"My name is Chantu,\" he says with a slight bow.")
                remove_answer("name")
            elseif var_0002 == "job" then
                add_dialogue("\"I am the Trinsic healer. I can perform a heal, a poison cure, or a resurrection on any of thy friends. Or on thee, of course.\"")
            elseif var_0002 == "murder" then
                add_dialogue("\"'Tis a sad state for Britannia when events such as these happen. Christopher was a good man. I hope that the villain is caught.\"")
                remove_answer("murder")
            elseif var_0002 == "services" then
                unknown_0860H(400, 50, 30) --- Guess: Performs healing, curing, or resurrection
            elseif var_0002 == "Fellowship" then
                add_dialogue("The healer frowns. \"The Fellowship does not appreciate the efforts of healers in Britannia. Although they do admirable things, The Fellowship is short-sighted when evaluating the need for healers. They believe that our work can be done through their so-called 'Triad of Inner Strength'.\"")
                if var_0001 then
                    add_dialogue("Chantu notices your medallion and his eyes widen.")
                    add_dialogue("\"Excuse me, " .. var_0000 .. ", I did not mean to offend thee.\"")
                end
                remove_answer("Fellowship")
            elseif var_0002 == "Klog" then
                add_dialogue("The healer shrugs. \"He does his duty as he sees fit. And I do mine.\"")
                remove_answer("Klog")
            elseif var_0002 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye.\"")
    elseif eventid == 0 then
        var_0002 = unknown_001CH(17) --- Guess: Gets object state
        var_0003 = random(1, 4)
        if var_0002 == 29 then
            if var_0003 == 1 then
                var_0004 = "@Feeling better?@"
            elseif var_0003 == 2 then
                var_0004 = "@How are we today?@"
            elseif var_0003 == 3 then
                var_0004 = "@Thy fever has lessened.@"
            elseif var_0003 == 4 then
                var_0004 = "@Try to sleep...@"
            end
            bark(17, var_0004)
        else
            unknown_092EH(17) --- Guess: Triggers a game event
        end
    end
end