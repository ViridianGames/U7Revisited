-- Function 04EA: Meryl's brief actress dialogue
function func_04EA(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid == 0 then
        local0 = callis_003B()
        local1 = callis_001C(callis_001B(-234))
        local2 = callis_Random2(4, 1)
        if local1 == 29 then
            if local2 == 1 then
                local3 = "@See the Passion Play!@"
            elseif local2 == 2 then
                local3 = "@The Fellowship presents...@"
            elseif local2 == 3 then
                local3 = "@Come view the Passion Play!@"
            elseif local2 == 4 then
                local3 = "@We shall entertain thee!@"
            end
            _ItemSay(local3, -234)
        else
            call_092EH(-234)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -234)
    say("You see a middle-aged actress with a very serious expression. She is unable to speak with you because she is concentrating on her part in the Passion Play. Perhaps you should speak to Paul.*")

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end