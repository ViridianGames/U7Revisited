-- Function 04B8: Runeb's Fellowship dialogue and combat trigger
function func_04B8(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -184)
    local0 = callis_003B()
    local1 = callis_001B(-184)
    if local0 == 7 then
        local2 = call_08FCH(-185, -184)
        if local2 then
            say("The gargoyle turns to you, frowning. He moves his massive hand to his mouth and use one finger to cross his lips. The Fellowship meeting is in progress.*")
        else
            say("The gargoyle, obviously in a hurry, ignores you.*")
        end
        return
    end

    _AddAnswer({"bye", "Fellowship", "job", "name"})

    if not get_flag(0x0249) then
        say("The gargoyle gives you a menacing glare. Judging by his size, he would make a formidable foe.")
        set_flag(0x0249, true)
    else
        say("\"To ask what you need?\" says Runeb.")
    end

    if not get_flag(0x0255) then
        if not get_flag(0x023F) then
            _AddAnswer("altar destruction")
        end
        if not get_flag(0x0240) then
            _AddAnswer("frame Quan")
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be Runeb.\"")
            set_flag(0x0255, true)
            _AddAnswer("Runeb")
            if not get_flag(0x023F) then
                _AddAnswer("altar destruction")
            end
            if not get_flag(0x0240) then
                _AddAnswer("frame Quan")
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"To be Fellowship clerk.\"")
        elseif answer == "Runeb" then
            say("\"To mean `busy one,'\" he says sarcastically.")
            _RemoveAnswer("Runeb")
        elseif answer == "Fellowship" then
            local3 = callis_0067()
            if local3 then
                say("\"To have a branch here. To meet at usual time each night.\"")
            else
                say("\"To have more important things to do now. To ask me later, human.\"")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "frame Quan" or answer == "altar destruction" then
            call_0911H(100)
            say("\"To be sorry you know that. To need now to kill Sarpling.\" He grins at you.~~\"To need now to kill you!\"*")
            calli_001D(0, local1)
            calli_003D(2, local1)
            return
        elseif answer == "bye" then
            say("He waits for you to leave before he returns to what he was doing.*")
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