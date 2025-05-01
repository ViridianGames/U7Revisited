-- Function 04D5: Catherine's child dialogue and gargoyle sympathy
function func_04D5(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(213, 0)
    local0 = call_0909H()
    add_answer({"bye", "job", "name"})

    local1 = call_08F7H(-214)
    if local1 then
        add_answer("gargoyle")
    end
    if get_flag(0x0285) then
        remove_answer("gargoyle")
        add_answer("For-Lem")
    end

    if not get_flag(0x0292) then
        add_dialogue("You see before you a young girl with a carefree expression. As she notices you, her eyes grow wide as she exclaims, \"Thou art the person in one of For... one of -my- story books! Thou art the Avatar!\"")
        set_flag(0x0292, true)
    else
        add_dialogue("\"How dost thou do, ", local0, " Avatar?\" She curtseys.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"My name is Catherine, ", local0, " Avatar.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I have no job, ", local0, " Avatar. I live with my father and mother here in Vesper.\"")
            add_answer({"Vesper", "mother", "father"})
        elseif answer == "father" then
            local2 = callis_0037(callis_001B(-203))
            add_dialogue("\"He is the overseer at the mines, ", local0, " Avatar.\"")
            if not local2 then
                add_dialogue("\"Of course, he's gone now...\" She looks down at her feet.")
            end
            remove_answer("father")
        elseif answer == "mother" then
            add_dialogue("\"Yes, ", local0, " Avatar. She is there right now.\" She points, apparently indicating her house.")
            remove_answer("mother")
        elseif answer == "Vesper" then
            add_dialogue("\"That is the name of our city, ", local0, " Avatar. If thou art lost, thou mayest wish to speak with the town clerk.\"")
            remove_answer("Vesper")
        elseif answer == "gargoyle" then
            add_dialogue("\"I'm sorry, ", local0, " Avatar, my mother told me never to speak with strangers.\" She quickly turns away.*")
            return
        elseif answer == "For-Lem" then
            add_dialogue("A tear glistens as it rolls gently down her cheek. \"He is no more. My -- my father killed him for talking to me, and -- and 'tis all thy fault!\" She turns away, sobbing.*")
            return
        elseif answer == "bye" then
            add_dialogue("\"Goodbye, ", local0, " Avatar.\"*")
            return
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