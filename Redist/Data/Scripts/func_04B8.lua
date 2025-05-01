-- Function 04B8: Runeb's Fellowship dialogue and combat trigger
function func_04B8(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(184, 0)
    local0 = callis_003B()
    local1 = callis_001B(-184)
    if local0 == 7 then
        local2 = call_08FCH(-185, -184)
        if local2 then
            add_dialogue("The gargoyle turns to you, frowning. He moves his massive hand to his mouth and use one finger to cross his lips. The Fellowship meeting is in progress.*")
        else
            add_dialogue("The gargoyle, obviously in a hurry, ignores you.*")
        end
        return
    end

    add_answer({"bye", "Fellowship", "job", "name"})

    if not get_flag(0x0249) then
        add_dialogue("The gargoyle gives you a menacing glare. Judging by his size, he would make a formidable foe.")
        set_flag(0x0249, true)
    else
        add_dialogue("\"To ask what you need?\" says Runeb.")
    end

    if not get_flag(0x0255) then
        if not get_flag(0x023F) then
            add_answer("altar destruction")
        end
        if not get_flag(0x0240) then
            add_answer("frame Quan")
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"To be Runeb.\"")
            set_flag(0x0255, true)
            add_answer("Runeb")
            if not get_flag(0x023F) then
                add_answer("altar destruction")
            end
            if not get_flag(0x0240) then
                add_answer("frame Quan")
            end
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"To be Fellowship clerk.\"")
        elseif answer == "Runeb" then
            add_dialogue("\"To mean `busy one,'\" he says sarcastically.")
            remove_answer("Runeb")
        elseif answer == "Fellowship" then
            local3 = callis_0067()
            if local3 then
                add_dialogue("\"To have a branch here. To meet at usual time each night.\"")
            else
                add_dialogue("\"To have more important things to do now. To ask me later, human.\"")
            end
            remove_answer("Fellowship")
        elseif answer == "frame Quan" or answer == "altar destruction" then
            call_0911H(100)
            add_dialogue("\"To be sorry you know that. To need now to kill Sarpling.\" He grins at you.~~\"To need now to kill you!\"*")
            calli_001D(0, local1)
            calli_003D(2, local1)
            return
        elseif answer == "bye" then
            add_dialogue("He waits for you to leave before he returns to what he was doing.*")
            break
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
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