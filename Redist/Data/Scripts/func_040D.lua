--- Best guess: Manages Gilberto’s dialogue, discussing the Trinsic murder, his attack, and dock duties, with password verification.
function func_040D(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 0 then
        return
    end

    start_conversation()
    -- debug flag setting to test conversations, REMOVE LATER
    --set_flag(61, true)

    switch_talk_to(13, 0)
    var_0000 = get_schedule(13)
    add_answer({"bye", "murder", "job", "name"})
    if get_flag(61) then
        add_answer("password")
    end
    if get_flag(63) then
        add_answer({"Klog", "Fellowship"})
    end
    if var_0000 == 7 or var_0000 == 0 or var_0000 == 1 then
        add_answer("ship")
    end
    if get_flag(67) then
        add_answer("Hook")
    end

    if get_flag(77) then
        add_dialogue("You see a grumpy fellow with a bloody bandage on his head.")
        set_flag(77, true)
        --unknown_001DH(16, -13)
        --add_dialogue("\"I am on duty. I have no time to talk.\"")
        else
            add_dialogue("\"Dost thou need something else?\" Gilberto asks. You notice his wound is healing nicely.")
    end

    while true do
        coroutine.yield()
        var_0001 = get_answer()
        if var_0001 == "name" then
            add_dialogue("\"I am Gilberto.\"")
            remove_answer("name")
        elseif var_0001 == "job" then
            add_dialogue("\"I have the night watch at the dock gate.\"")
        elseif var_0001 == "murder" then
            add_dialogue("\"It must have occurred shortly before I was knocked out.\"")
            add_answer("knocked")
            remove_answer("murder")
        elseif var_0001 == "knocked" then
            add_dialogue("\"It was just about sunrise. I was looking out to the sea. All of a sudden, I felt a blow on the back of mine head.\"")
            add_dialogue("He winces in pain.")
            add_answer({"pain", "blow"})
            remove_answer("knocked")
        elseif var_0001 == "pain" then
            add_dialogue("Gilberto still seems a little wobbly, but his gesture indicates that he does not desire your aid.")
            add_dialogue("\"My skull is still ringing, but I shall be all right momentarily.\"")
            remove_answer("pain")
        elseif var_0001 == "blow" then
            add_dialogue("\"The next thing I knew, I was on the ground. Johnson, the guard for the next watch, was shaking me. I had been out about ten minutes.")
            add_dialogue("I knew that because the sun had just peeked over the horizon. And 'The Crown Jewel' had gone and sailed!\"")
            add_answer({"Crown Jewel", "Johnson"})
            remove_answer("blow")
        elseif var_0001 == "Crown Jewel" then
            add_dialogue("\"Did I forget to say? That is a ship that was docked here all night. I believe it was about to sail for Britain.")
            add_dialogue("Thou couldst ask Gargan the Shipwright to make sure. Anyway, I did not see mine attackers,\" the guard grumbles.")
            set_flag(64, true)
            add_answer({"Gargan", "attackers"})
            remove_answer("Crown Jewel")
        elseif var_0001 == "attackers" then
            add_dialogue("\"Hmmm. I wonder if they jumped onto the ship! They could be all the way to Britain by now!\"")
            remove_answer("attackers")
        elseif var_0001 == "Gargan" then
            add_dialogue("\"He is a good man but thou mayest not wish to stand too close to him. Thou mayest catch something.\"")
            remove_answer("Gargan")
        elseif var_0001 == "ship" then
            add_dialogue("\"If thou dost want a ship, thou must get a deed from the shipwright. Thou must also have the password to leave town.\"")
            remove_answer("ship")
            add_answer("password")
        elseif var_0001 == "password" then
            add_dialogue("\"What is it?\"")
            var_0001 = {"Please", "Long live the king", "Uhh, I don't know"}
            if get_flag(61) then
                var_0001 = {"Please", "Long live the king", "Uhh, I don't know", "Blackbird"}
            end
            var_0002 = unknown_090BH(var_0001)
            if var_0002 == "Blackbird" then
                var_0003 = unknown_0834H()
                if var_0003 then
                    add_dialogue("\"All right. Thou mayest pass.\"")
                else
                    add_dialogue("\"Thou mayest not pass.\"")
                end
                return
            else
                add_dialogue("\"Thou dost not know the password. The Mayor can give thee the proper password.\"")
            end
        elseif var_0001 == "Johnson" then
            add_dialogue("\"He takes the morning watch at the dock.\"")
            remove_answer("Johnson")
        elseif var_0001 == "Fellowship" then
            add_dialogue("He shrugs.")
            add_dialogue("\"Thou art asking the wrong man. I suppose they are all right. I have never had trouble with them.\"")
            remove_answer("Fellowship")
        elseif var_0001 == "Hook" then
            add_dialogue("The guard thinks a moment.")
            add_dialogue("\"No. I cannot say that I saw a man with a hook.\"")
            remove_answer("Hook")
        elseif var_0001 == "Klog" then
            add_dialogue("\"I have not had many dealings with him.\"")
            remove_answer("Klog")
        elseif var_0001 == "bye" then
            add_dialogue("\"Goodbye. Watch thy back.\"")
            clear_answers()
            --break
        end
    end
    
    return
end