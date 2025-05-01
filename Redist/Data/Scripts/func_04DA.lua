-- Function 04DA: Anmanivas's hostile dialogue and attack trigger
function func_04DA(eventid, itemref)
    -- Local variables (15 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(218, 0)
    local0 = callis_001B(-218)
    local1 = callis_001B(-217)
    local2 = call_0908H()
    local3 = call_0909H()
    local4 = "the Avatar"
    local5 = callis_003C(local1)
    local6 = callis_001C(local0)
    _AddAnswer({"bye", "job", "name"})

    if local5 == 1 then
        say("The gargoyle's anger is so great that he resists the spell.*")
        calli_003D(2, local0)
        calli_003D(2, local1)
        return
    end

    if local6 == 16 then
        say("The gargoyle is obviously displeased with the intrusion of your presence.")
        while true do
            local answer = wait_for_answer()

            if answer == "name" then
                say("\"To have no desire to tell you. To demand to know who you are!\"")
                local7 = call_090BH({local3, local4, local2})
                if local7 == local4 then
                    local8 = 0
                    local9 = callis_GetPartyMembers()
                    for local10, local11 in ipairs(local9) do
                        local8 = local8 + 1
                    end
                    if local8 == 1 then
                        local13 = "human"
                    else
                        local13 = "humans"
                    end
                    say("The gargoyle growls as he turns to look at you. He stands, ")
                    local14 = call_08F7H(-217)
                    if not local14 then
                        say("setting a hand on the shoulder of the gargoyle next to him.*")
                        switch_talk_to(217, 0)
                        say("The other gargoyle also stands. Anger flashes across his face as he points a finger at you.~~ \"To be the cause for our unhappiness, ", local13, "!\"*")
                        _HideNPC(-217)
                        switch_talk_to(218, 0)
                    end
                    say("\"To be the reason for our poverty. To die, ", local13, ", to die!\"*")
                    calli_001D(0, local0)
                    calli_001D(0, local1)
                    calli_003D(2, local1)
                    calli_003D(2, local0)
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
        say("The gargoyle stops only long enough to give you a menacing stare.*")
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