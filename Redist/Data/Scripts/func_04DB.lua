require "U7LuaFuncs"
-- Function 04DB: Aurvidlem's provisioner dialogue and resentment
function func_04DB(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_092FH(-219)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -219)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0298) then
        say("The gargoyle standing before you has a sour expression on his face.")
        set_flag(0x0298, true)
    else
        say("\"To offer you greetings, human,\" says Aurvidlem.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be called Aurvidlem. To recognize you to be the Avatar.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"To provide provisions for others in Vesper.\"")
            _AddAnswer({"Vesper", "others", "buy provisions"})
        elseif answer == "Vesper" then
            say("\"To be a town filled with prejudice and hatred. To know the humans expect us to begin a violent confrontation.~~\"To believe the humans deserve it,\" he shrugs, \"but to hope my brethren display more control than that.\"")
            _RemoveAnswer("Vesper")
        elseif answer == "buy provisions" then
            local0 = callis_001C(callis_001B(-219))
            if local0 ~= 7 then
                say("\"To be not selling at this time. To come back tomorrow to buy provisions.\"")
            else
                local1 = callis_0028(-359, -359, 644, -357)
                call_084CH()
                local2 = callis_0028(-359, -359, 644, -357)
                if local2 - local1 > 29 then
                    set_flag(0x027F, true)
                end
            end
            _RemoveAnswer("buy provisions")
        elseif answer == "others" then
            if not get_flag(0x027F) then
                say("\"To have only a few gargoyles living in town. To know mainly Wis-Sur, and,\" he gives a slight grunt, \"Ansikart. Also to know of some wingless ones.\"")
            else
                say("\"To have only a few gargoyles living in town. To know mainly Wis-Sur and Ansikart, and to know of some wingless ones.\"")
            end
            _AddAnswer("Ansikart")
            _RemoveAnswer("others")
        elseif answer == "Ansikart" then
            say("His eyes shift quickly from left to right before finally settling on you.~~\"To know since change in Wis-Sur, Ansikart gained too much respect. To be sure that I have studied more and would be a wiser and better leader here. To be dissatisfied with Ansikart as choice.\"")
            _AddAnswer("change")
            _RemoveAnswer("Ansikart")
        elseif answer == "change" then
            say("\"To be unsure when change happened, but has affected Wis-Sur greatly. To now see him avoid others and shut himself away. To be concerned for Wis-Sur.\"")
            _RemoveAnswer("change")
        elseif answer == "bye" then
            say("\"To bid you goodbye.\"*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end