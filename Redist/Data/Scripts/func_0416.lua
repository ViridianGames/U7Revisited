-- Manages Caroline's dialogue in Trinsic, covering Fellowship recruitment, Christopher's murder, and ambient slogans.
function func_0416(eventid, itemref)
    local local0, local1, local2, local3, local4

    if eventid == 1 then
        switch_talk_to(-22, 0)
        local0 = get_schedule()
        local1 = switch_talk_to(-22)

        if local0 == 7 then
            local2 = apply_effect(-16, -22) -- Unmapped intrinsic 08FC
            if local2 then
                say("Caroline asks you to keep your voice down. The Fellowship meeting is in progress.*")
            else
                say("\"Oh! I cannot stop to speak with thee now! I am late for the Fellowship meeting!\"*")
            end
            return
        end

        add_answer({"bye", "murder", "job", "name"})

        if not get_flag(86) then
            say("You see a young woman with a bright smile.")
            set_flag(86, true)
        else
            say("\"Hello again!\" Caroline says brightly.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My parents named me Caroline,\" she says proudly.")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I have no 'job' per se. I have devoted mine energies to helping The Fellowship. I hope to recruit new members.\"")
                add_answer("Fellowship")
            elseif answer == "murder" then
                say("She looks concerned. \"'Tis awful! Christopher was a nice man. Didst thou know he was one of our members? I cannot believe he is dead...\"")
                remove_answer("murder")
                add_answer("members")
            elseif answer == "members" then
                say("\"Of The Fellowship. We meet every night at the hall. Thou shouldst visit!\"")
                remove_answer("members")
            elseif answer == "Fellowship" then
                apply_effect() -- Unmapped intrinsic 0919
                remove_answer("Fellowship")
                add_answer({"philosophy", "society"})
            elseif answer == "society" then
                say("\"Every night at nine o'clock we have a meeting in the Fellowship hall. Thou mayest consider thyself invited to attend.\"")
                remove_answer("society")
            elseif answer == "philosophy" then
                apply_effect() -- Unmapped intrinsic 091A
                remove_answer("philosophy")
            elseif answer == "bye" then
                say("\"Goodbye!\"*")
                break
            end
        end
    elseif eventid == 0 then
        local1 = switch_talk_to(-22)
        local3 = random(1, 4)
        local4 = check_item_state(-22)

        if local4 == 12 then
            if local3 == 1 then
                local4 = "@Come to Fellowship Hall!@"
            elseif local3 == 2 then
                local4 = "@Strive For Unity!@"
            elseif local3 == 3 then
                local4 = "@Trust Thy Brother!@"
            elseif local3 == 4 then
                local4 = "@Worthiness Precedes Reward!@"
            end
            item_say(local4, -22)
        else
            switch_talk_to(-22)
        end
    end
    return
end