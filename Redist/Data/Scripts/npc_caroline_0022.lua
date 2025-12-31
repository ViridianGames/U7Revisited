--- Best guess: Handles dialogue with Caroline, a Fellowship recruiter in Trinsic, discussing her role and the local murder, with invitations to Fellowship meetings.
function npc_caroline_0022(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        switch_talk_to(22)
        var_0000 = get_schedule_time()
        if var_0000 == 7 then
            var_0001 = (get_schedule(22) == 16)
            if var_0001 then
                add_dialogue("Caroline asks you to keep your voice down. The Fellowship meeting is in progress.")
            else
                add_dialogue("\"Oh! I cannot stop to speak with thee now! I am late for the Fellowship meeting!\"")
            end
            return
        end
        add_answer({"bye", "murder", "job", "name"})
        if not get_flag(86) then
            add_dialogue("You see a young woman with a bright smile.")
            set_flag(86, true)
        else
            add_dialogue("\"Hello again!\" Caroline says brightly.")
        end
        while true do
            coroutine.yield()
            var_0002 = get_answer()
            if var_0002 == "name" then
                add_dialogue("\"My parents named me Caroline,\" she says proudly.")
                remove_answer("name")
            elseif var_0002 == "job" then
                add_dialogue("\"I have no 'job' per se. I have devoted mine energies to helping The Fellowship. I hope to recruit new members.\"")
                add_answer("Fellowship")
            elseif var_0002 == "murder" then
                add_dialogue("She looks concerned. \"'Tis awful! Christopher was a nice man. Didst thou know he was one of our members? I cannot believe he is dead...\"")
                remove_answer("murder")
                add_answer("members")
            elseif var_0002 == "members" then
                add_dialogue("\"Of The Fellowship. We meet every night at the hall. Thou shouldst visit!\"")
                remove_answer("members")
            elseif var_0002 == "Fellowship" then
                debug_print("Clicked 'Fellowship'")
                utility_fellowship_intro_1049()
                remove_answer("Fellowship")
                add_answer({"society"})
            elseif var_0002 == "society" then
                add_dialogue("\"Every night at nine o'clock we have a meeting in the Fellowship hall. Thou mayest consider thyself invited to attend.\"")
                remove_answer("society")
            elseif var_0002 == "philosophy" then
                remove_answer("philosophy")
                utility_fellowship_philosophy_1050()
            elseif var_0002 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye!\"")
        clear_answers()
    elseif eventid == 0 then
        var_0002 = get_schedule_type(22) --- Guess: Gets object state
        var_0003 = random(1, 4)
        if var_0002 == 12 then
            if var_0003 == 1 then
                var_0004 = "@Come to Fellowship Hall!@"
            elseif var_0003 == 2 then
                var_0004 = "@Strive For Unity!@"
            elseif var_0003 == 3 then
                var_0004 = "@Trust Thy Brother!@"
            elseif var_0003 == 4 then
                var_0004 = "@Worthiness Precedes Reward!@"
            end
            bark(22, var_0004)
        else
            utility_unknown_1070(22) --- Guess: Triggers a game event
        end
    end
end