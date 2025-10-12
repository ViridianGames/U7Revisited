--- Best guess: Manages Johnson’s dialogue, handling dock duties, Fellowship membership, and password verification for Trinsic.
function func_040E(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    --set_flag(61, true)

    if eventid == 0 then
        return
    end

    start_conversation()
    switch_talk_to(14, 0)
    var_0000 = get_schedule_time()
    if var_0000 == 7 then
        var_0001 = get_schedule(14)
        if var_0001 then
            add_dialogue("\"I will speak with thee after the Fellowship meeting.\"")
        else
            add_dialogue("\"I must get to the Fellowship meeting! I am late! May we speak tomorrow?\"")
        end
        return
    end
    add_answer({"bye", "job", "name"})
    if get_flag(61) then
        add_answer("password")
    end
    if get_flag(60) then
        add_answer("murder")
    end
    if get_flag(63) then
        add_answer({"Hook", "Klog", "Fellowship"})
    end
    if get_flag(64) then
        add_answer("Crown Jewel")
    end
    if not get_flag(78) then
        add_dialogue("You see an alert and no-nonsense guard.")
        set_flag(78, true)
    else
        add_dialogue("\"What is it?\" Johnson asks, sternly.")
    end
    while true do
        coroutine.yield()
        local answer = get_answer()
        debug_print("Answer is " .. answer .. ".")
        if answer == "name" then
            add_dialogue("\"Johnson.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I have the morning watch guarding the dock. I authorize the comings and goings of every ship.\"")
            add_answer("ship")
        elseif answer == "murder" then
            add_dialogue("\"I did hear of this. When I arrived at my post at sunrise, I found Gilberto lying felled on the ground.")
            add_dialogue("If thou art asking if I saw anything -- I did not. No one hath passed by me since I arrived at the dock.\"")
            remove_answer("murder")
        elseif answer == "Crown Jewel" then
            add_dialogue("\"The boat left just after sunrise. It did sail to Britain, I believe. Thou canst ask Gargan the Shipwright about that.\"")
            remove_answer("Crown Jewel")
        elseif answer == "Fellowship" then
            var_0002 = ask_yes_no("\"Yes, I am a member. Wouldst thou like to join?\"")
            if var_0002 then
                add_dialogue("\"Then thou shouldst go to see Batlin in Britain.\"")
            else
                add_dialogue("\"'Tis thy loss.\"")
            end
            remove_answer("Fellowship")
        elseif answer == "Klog" then
            add_dialogue("\"Good man. He is our branch leader here in Trinsic.\"")
            remove_answer("Klog")
        elseif answer == "ship" then
            add_dialogue("\"If thou dost want a ship, thou must get a deed from the shipwright. Thou must also have the password to leave town.\"")
            add_answer({"deed", "password"})
            remove_answer("ship")
        elseif answer == "password" then
            if get_flag(61) then
                var_0003 = ask_multiple_choice({"\"What is it?\"", "Please", "Long live the king", "Uhh, I don't know", "Blackbird"})
            else
                var_0003 = ask_multiple_choice({"\"What is it?\"", "Please", "Long live the king", "Uhh, I don't know"})
            end
            if var_0003 == "Blackbird" then
                add_dialogue("\"Very well, thou mayest pass.\"")
                --clear_answers()
                --unknown_0834H()
                --return
            else
                add_dialogue("\"Thou dost not know the password. I am sorry. The Mayor may give thee the proper password.\"")
                set_flag(66, true)
            end
        elseif answer == "Hook" then
            add_dialogue("\"A man with a hook? No, I saw no one all night or all morning.\"")
            remove_answer("Hook")
        elseif answer == "deed" then
            add_dialogue("\"Thou canst purchase that from Gargan the Shipwright.\"")
            remove_answer("deed")
        elseif answer == "bye" then
            break
        end
    end
    add_dialogue("\"Good day.\"")
    clear_answers()
    return
end