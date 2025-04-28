require "U7LuaFuncs"
-- Function 04D9: Foranamo's hostile dialogue and attack trigger
function func_04D9(eventid, itemref)
    -- Local variables (16 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -217)
    local0 = callis_001B(-217)
    local1 = callis_001B(-218)
    local2 = call_0908H()
    local3 = call_0909H()
    local4 = "the Avatar"
    local5 = callis_003C(local0)
    local6 = callis_001C(local0)
    _AddAnswer({"bye", "job", "name"})

    if local5 == 1 then
        say("The gargoyle's hatred is so bitter that he resists the spell.*")
        calli_003D(2, local0)
        calli_003D(2, local1)
        return
    end

    if local6 == 16 then
        say("The gargoyle stares at you, displeased at the interruption.")
        while true do
            local answer = wait_for_answer()

            if answer == "name" then
                say("\"To have no desire to tell you. To demand to know who you are!\"")
                local7 = call_090BH({local3, local4, local2})
                if local7 == local4 then
                    say("As the gargoyle looks up at you, anger crosses his face. He stands quickly, overturning his drink.")
                    local8 = 0
                    local9 = callis_GetPartyMembers()
                    for local10, local11 in ipairs(local9) do
                        local8 = local8 + 1
                    end
                    if local8 == 1 then
                        local13 = "human"
                        local14 = " he says, pointing at you."
                    else
                        local13 = "humans"
                        local14 = " he says, pointing at you and your companions."
                    end
                    say("\"^", local13, "!\"", local14, " \"To be the cause for our unhappiness.\"")
                    local15 = call_08F7H(-218)
                    if not local15 then
                        _SwitchTalkTo(0, -218)
                        say("The gargoyle by his side also rises.~~\"To be the reason for our poverty. To die, ", local13, ", to die!\"*")
                        _HideNPC(-218)
                        _SwitchTalkTo(0, -217)
                        say("The two gargoyles force the table from their path with ease as they charge to attack you.*")
                    else
                        say("He forces the table from his path with ease as he charges to attack you.*")
                    end
                    calli_001D(0, local0)
                    calli_001D(0, local1)
                    calli_003D(2, local0)
                    calli_003D(2, local1)
                    return
                else
                    say("\"To tell you to go away!\"*")
                    return
                end
                _RemoveAnswer("name")
            elseif answer == "job" then
                say("\"To have none!\" He glares fiercely at you.\"")
                _RemoveAnswer("job")
            elseif answer == "bye" then
                say("He grunts his dismissal.*")
                return
            end
        end
    else
        say("Though he glares as he passes, the gargoyle seems much too intent on reaching his destination to bother with you.*")
        return
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