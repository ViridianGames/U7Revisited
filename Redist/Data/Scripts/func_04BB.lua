-- Function 04BB: Silamo's wingless gardener dialogue and social tensions
function func_04BB(eventid, itemref)
    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -187)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x024C) then
        say("You see a frowning gargoyle.")
        set_flag(0x024C, true)
    else
        say("\"To ask what you need, human,\" says Silamo.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be named `Silamo.'\"")
            if get_flag(0x023D) then
                _AddAnswer("wingless status")
            end
            _RemoveAnswer("name")
            _AddAnswer("Silamo")
        elseif answer == "Silamo" then
            say("\"To know my name if I were winged.\" He scowls at you.")
            _RemoveAnswer("Silamo")
        elseif answer == "job" then
            say("\"To be the gardener,\" he shrugs, \"nothing more.\"~~ He does not seem to be interested in speaking with you.")
        elseif answer == "wingless status" then
            say("He stares at you for a moment.~~\"To be right, human.~~ \"To feel I am treated less for an absence of wings. To see Quaeven treated better since joining The Fellowship. To be devoted to the altar of singularity. But, perhaps to change if The Fellowship cares not about wings.\"")
            _AddAnswer({"Quaeven", "treated"})
            _RemoveAnswer("wingless status")
        elseif answer == "Quaeven" then
            say("\"To be also without wings, but to be respected as if he were winged.\"")
            _RemoveAnswer("Quaeven")
        elseif answer == "treated" then
            say("\"To see many others include him in many events from which I am excluded. To know others include him in many more decision-making councils, too.\"")
            _RemoveAnswer("treated")
            _AddAnswer("others")
        elseif answer == "others" then
            say("\"Gargoyles in The Fellowship.\"")
            _RemoveAnswer("others")
        elseif answer == "bye" then
            say("\"To get back to work.\"*")
            break
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