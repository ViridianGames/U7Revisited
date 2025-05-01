-- Function 04E9: Paul's actor dialogue and Passion Play performance
function func_04E9(eventid, itemref)
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    if eventid == 0 then
        local0 = callis_003B()
        local11 = callis_001C(callis_001B(-233))
        local12 = callis_Random2(4, 1)
        if local11 == 29 and (local0 == 5 or local0 == 7 or local0 == 0) then
            if local12 == 1 then
                local9 = "@See the Passion Play!@"
            elseif local12 == 2 then
                local9 = "@The Fellowship presents...@"
            elseif local12 == 3 then
                local9 = "@Come view the Passion Play!@"
            elseif local12 == 4 then
                local9 = "@We shall entertain thee!@"
            end
            bark(233, local9)
        else
            call_092EH(-233)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(233, 0)
    local0 = callis_001C(callis_001B(-233))
    add_answer({"bye", "job", "name"})

    if not get_flag(0x02B8) then
        add_dialogue("You see a young entertainer who beckons to you.")
        set_flag(0x02B8, true)
    else
        add_dialogue("\"Yes?\" Paul asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Paul. My colleagues' names are Meryl and Dustin.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"We perform a Passion Play about The Fellowship. It costs only 2 gold per person to see. If thou dost want us to perform it, please say so.\"")
            add_answer({"perform", "Fellowship", "Passion Play"})
        elseif answer == "Passion Play" then
            add_dialogue("\"A Passion Play is a morality tale performed on stage.\"")
            remove_answer("Passion Play")
        elseif answer == "Fellowship" then
            add_dialogue("\"It would be much simpler to view the play.\"")
            remove_answer("Fellowship")
        elseif answer == "perform" then
            if local0 ~= 29 then
                add_dialogue("\"I am sorry to say we are on our break. Please return to the stage area during normal hours.\"")
            else
                add_dialogue("\"Wouldst thou like to see our Passion Play?\"")
                if not call_090AH() then
                    add_dialogue("\"Some other time, then, I hope.\"*")
                    return
                end
                local1 = call_08F7H(-234)
                local2 = call_08F7H(-235)
                if local1 and local2 then
                    local3 = callis_GetPartyMembers()
                    local4 = 0
                    for local5, local6 in ipairs(local3) do
                        local4 = local4 + 1
                    end
                    local7 = callis_0028(-359, -359, 644, -357)
                    if local7 >= local4 * 2 then
                        local9 = callis_002B(true, -359, -359, 644, local4 * 2)
                        add_dialogue("Paul takes your gold. \"We thank thee. If thou wouldst make thyself comfortable, we shall begin.\"")
                        call_08C7H()
                    else
                        add_dialogue("\"Oh dear. I am afraid thou dost not have enough gold to pay for the performance. Some other time, I hope.\"*")
                        return
                    end
                else
                    add_dialogue("\"I am sorry. It seems my fellow thespians are not available. The Passion Play has temporarily closed.\"*")
                    return
                end
            end
        elseif answer == "bye" then
            add_dialogue("The actor bows to you.*")
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