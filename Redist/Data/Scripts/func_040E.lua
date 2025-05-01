-- Function 040E: Manages Johnson's dialogue and interactions
function func_040E(itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid() == 0 then
        abort()
    end
    switch_talk_to(14, 0)
    local0 = callis_003B()
    if local0 == 7 then
        local1 = call_08FCH(-16, -14)
        if local1 then
            say("\"I will speak with thee after the Fellowship meeting.\"")
        else
            say("\"I must get to the Fellowship meeting! I am late! May we speak tomorrow?\"")
        end
        abort()
    end
    _AddAnswer({"bye", "job", "name"})
    if get_flag(61) then
        _AddAnswer("password")
    end
    if get_flag(60) then
        _AddAnswer("murder")
    end
    if get_flag(63) then
        _AddAnswer({"Hook", "Klog", "Fellowship"})
    end
    if get_flag(64) then
        _AddAnswer("Crown Jewel")
    end
    if not get_flag(78) then
        say("You see an alert and no-nonsense guard.")
        set_flag(78, true)
    else
        say("\"What is it?\" Johnson asks, sternly.")
    end
    while true do
        if cmp_strings("name", 1) then
            say("\"Johnson.\"")
            _RemoveAnswer("name")
        elseif cmp_strings("job", 1) then
            say("\"I have the morning watch guarding the dock. I authorize the comings and goings of every ship.\"")
            _AddAnswer("ship")
        elseif cmp_strings("murder", 1) then
            say("\"I did hear of this. When I arrived at my post at sunrise, I found Gilberto lying felled on the ground. If thou art asking if I saw anything -- I did not. No one hath passed by me since I arrived at the dock.\"")
            _RemoveAnswer("murder")
        elseif cmp_strings("Crown Jewel", 1) then
            say("\"The boat left just after sunrise. It did sail to Britain, I believe. Thou canst ask Gargan the Shipwright about that.\"")
            _RemoveAnswer("Crown Jewel")
        elseif cmp_strings("Fellowship", 1) then
            say("\"Yes, I am a member. Wouldst thou like to join?\"")
            local2 = call_090AH()
            if local2 then
                say("\"Then thou shouldst go to see Batlin in Britain.\"")
            else
                say("\"'Tis thy loss.\"")
            end
            _RemoveAnswer("Fellowship")
        elseif cmp_strings("Klog", 1) then
            say("\"Good man. He is our branch leader here in Trinsic.\"")
            _RemoveAnswer("Klog")
        elseif cmp_strings("ship", 1) then
            say("\"If thou dost want a ship, thou must get a deed from the shipwright. Thou must also have the password to leave town.\"")
            _AddAnswer({"deed", "password"})
            _RemoveAnswer("ship")
        elseif cmp_strings("password", 1) then
            say("\"What is it?\"")
            local3 = {"Please", "Long live the king", "Uhh, I don't know"}
            if get_flag(61) then
                table.insert(local3, "Blackbird")
            end
            local2 = call_090BH(local3)
            if local2 == "Blackbird" then
                local4 = call_0834H()
                if local4 then
                    say("\"Very well, thou mayest pass.\"")
                else
                    say("\"Thou mayest not pass.\"")
                end
                abort()
            else
                say("\"Thou dost not know the password. I am sorry. The Mayor may give thee the proper password.\"")
                set_flag(66, true)
            end
        elseif cmp_strings("Hook", 1) then
            say("\"A man with a hook? No, I saw no one all night or all morning.\"")
            _RemoveAnswer("Hook")
        elseif cmp_strings("deed", 1) then
            say("\"Thou canst purchase that from Gargan the Shipwright.\"")
            _RemoveAnswer("deed")
        elseif cmp_strings("bye", 1) then
            say("\"Good day.\"")
            break
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function say(...)
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

function abort()
    -- Placeholder
end