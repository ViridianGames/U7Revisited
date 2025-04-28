require "U7LuaFuncs"
-- Function 04EB: Dustin's brief Passion Play actor dialogue
function func_04EB(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid == 0 then
        local0 = callis_003B()
        local1 = callis_001C(callis_001B(-235))
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
            _ItemSay(local3, -235)
        else
            call_092EH(-235)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -235)
    say("You see a short, stocky actor in his mid- to late forties. He cannot speak to you now because he is concentrating.ConcurrentModificationException his lines for the Passion Play. Perhaps you should speak to Paul.*")

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