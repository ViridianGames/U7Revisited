-- Manages Chantu's dialogue in Trinsic, covering his healing services, views on the Fellowship, and the murder.
function func_0411(eventid, itemref)
    local local0, local1, local2, local3, local4

    if eventid == 1 then
        switch_talk_to(17, 0)
        local0 = get_player_name()
        local1 = get_item_type()

        add_answer({"bye", "services", "murder", "job", "name"})
        if not get_flag(63) then
            add_answer({"Klog", "Fellowship"})
        end

        if not get_flag(82) then
            say("You see a solemn fellow in healer's robes.")
            set_flag(82, true)
        else
            say("\"Hello, again,\" Chantu says. \"How may I help thee?\"")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name is Chantu,\" he says with a slight bow.")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I am the Trinsic healer. I can perform a heal, a poison cure, or a resurrection on any of thy friends. Or on thee, of course.\"")
            elseif answer == "murder" then
                say("\"'Tis a sad state for Britannia when events such as these happen. Christopher was a good man. I hope that the villain is caught.\"")
                remove_answer("murder")
            elseif answer == "services" then
                apply_effect(400, 50, 30) -- Unmapped intrinsic 0860
            elseif answer == "Fellowship" then
                say("The healer frowns. \"The Fellowship does not appreciate the efforts of healers in Britannia. Although they do admirable things, The Fellowship is short-sighted when evaluating the need for healers. They believe that our work can be done through their so-called 'Triad of Inner Strength'.\"")
                if local1 then
                    say("Chantu notices your medallion and his eyes widen.")
                    say("\"Excuse me, " .. local0 .. ", I did not mean to offend thee.\"")
                end
                remove_answer("Fellowship")
            elseif answer == "Klog" then
                say("The healer shrugs. \"He does his duty as he sees fit. And I do mine.\"")
                remove_answer("Klog")
            elseif answer == "bye" then
                say("\"Goodbye.\"*")
                break
            end
        end
    elseif eventid == 0 then
        local2 = switch_talk_to(17)
        local3 = random(1, 4)
        local4 = check_item_state(-17)

        if local4 == 29 then
            if local3 == 1 then
                local4 = "@Feeling better?@"
            elseif local3 == 2 then
                local4 = "@How are we today?@"
            elseif local3 == 3 then
                local4 = "@Thy fever has lessened.@"
            elseif local3 == 4 then
                local4 = "@Try to sleep...@"
            end
            item_say(local4, -17)
        else
            switch_talk_to(17)
        end
    end
    return
end