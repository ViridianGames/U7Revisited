-- Function 040D: Manages Gilberto's dialogue and interactions
function func_040D(itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid() == 0 then
        abort()
    end
    switch_talk_to(13, 0)
    local0 = callis_003B()
    add_answer({"bye", "murder", "job", "name"})
    if get_flag(61) then
        add_answer("password")
    end
    if get_flag(63) then
        add_answer({"Klog", "Fellowship"})
    end
    if local0 == 7 or local0 == 0 or local0 == 1 then
        add_answer("ship")
    end
    if get_flag(67) then
        add_answer("Hook")
    end
    if not get_flag(77) then
        add_dialogue("You see a grumpy fellow with a bloody bandage on his head.")
        set_flag(77, true)
        callis_001D(16, callis_001B(-13, -13))
    else
        add_dialogue("\"Dost thou need something else?\" Gilberto asks. You notice his wound is healing nicely.")
    end
    while true do
        if cmp_strings("name", 1) then
            add_dialogue("\"I am Gilberto.\"")
            remove_answer("name")
        elseif cmp_strings("job", 1) then
            add_dialogue("\"I have the night watch at the dock gate.\"")
        elseif cmp_strings("murder", 1) then
            add_dialogue("\"It must have occurred shortly before I was knocked out.\"")
            add_answer("knocked")
            remove_answer("murder")
        elseif cmp_strings("knocked", 1) then
            add_dialogue("\"It was just about sunrise. I was looking out to the sea. All of a sudden, I felt a blow on the back of mine head.\"~~ He winces in pain.")
            add_answer({"pain", "blow"})
            remove_answer("knocked")
        elseif cmp_strings("pain", 1) then
            add_dialogue("Gilberto still seems a little wobbly, but his gesture indicates that he does not desire your aid.~\"My skull is still ringing, but I shall be all right momentarily.\"")
            remove_answer("pain")
        elseif cmp_strings("blow", 1) then
            add_dialogue("\"The next thing I knew, I was on the ground. Johnson, the guard for the next watch, was shaking me. I had been out about ten minutes. I knew that because the sun had just peeked over the horizon. And 'The Crown Jewel' had gone and sailed!\"")
            add_answer({"Crown Jewel", "Johnson"})
            remove_answer("blow")
        elseif cmp_strings("Crown Jewel", 1) then
            add_dialogue("\"Did I forget to say? That is a ship that was docked here all night. I believe it was about to sail for Britain. Thou couldst ask Gargan the Shipwright to make sure. Anyway, I did not see mine attackers,\" the guard grumbles.")
            set_flag(64, true)
            add_answer({"Gargan", "attackers"})
            remove_answer("Crown Jewel")
        elseif cmp_strings("attackers", 1) then
            add_dialogue("\"Hmmm. I wonder if they jumped onto the ship! They could be all the way to Britain by now!\"")
            remove_answer("attackers")
        elseif cmp_strings("Gargan", 1) then
            add_dialogue("\"He is a good man but thou mayest not wish to stand too close to him. Thou mayest catch something.\"")
            remove_answer("Gargan")
        elseif cmp_strings("ship", 1) then
            add_dialogue("\"If thou dost want a ship, thou must get a deed from the shipwright. Thou must also have the password to leave town.\"")
            remove_answer("ship")
            add_answer("password")
        elseif cmp_strings("password", 1) then
            add_dialogue("\"What is it?\"")
            local1 = {"Please", "Long live the king", "Uhh, I don't know"}
            if get_flag(61) then
                table.insert(local1, "Blackbird")
            end
            local2 = call_090BH(local1)
            if local2 == "Blackbird" then
                local3 = call_0834H()
                if local3 then
                    add_dialogue("\"All right. Thou mayest pass.\"")
                else
                    add_dialogue("\"Thou mayest not pass.\"")
                end
                abort()
            else
                add_dialogue("\"Thou dost not know the password. The Mayor can give thee the proper password.\"")
            end
        elseif cmp_strings("Johnson", 1) then
            add_dialogue("\"He takes the morning watch at the dock.\"")
            remove_answer("Johnson")
        elseif cmp_strings("Fellowship", 1) then
            add_dialogue("He shrugs.~~\"Thou art asking the wrong man. I suppose they are all right. I have never had trouble with them.\"")
            remove_answer("Fellowship")
        elseif cmp_strings("Hook", 1) then
            add_dialogue("The guard thinks a moment.~~\"No. I cannot say that I saw a man with a hook.\"")
            remove_answer("Hook")
        elseif cmp_strings("Klog", 1) then
            add_dialogue("\"I have not had many dealings with him.\"")
            remove_answer("Klog")
        elseif cmp_strings("bye", 1) then
            add_dialogue("\"Goodbye. Watch thy back.\"")
            break
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function add_dialogue(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function cmp_strings(str, count)
    return false -- Placeholder
end