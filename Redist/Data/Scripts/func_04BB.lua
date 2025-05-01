-- Function 04BB: Silamo's wingless gardener dialogue and social tensions
function func_04BB(eventid, itemref)
    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(187, 0)
    add_answer({"bye", "job", "name"})

    if not get_flag(0x024C) then
        add_dialogue("You see a frowning gargoyle.")
        set_flag(0x024C, true)
    else
        add_dialogue("\"To ask what you need, human,\" says Silamo.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"To be named `Silamo.'\"")
            if get_flag(0x023D) then
                add_answer("wingless status")
            end
            remove_answer("name")
            add_answer("Silamo")
        elseif answer == "Silamo" then
            add_dialogue("\"To know my name if I were winged.\" He scowls at you.")
            remove_answer("Silamo")
        elseif answer == "job" then
            add_dialogue("\"To be the gardener,\" he shrugs, \"nothing more.\"~~ He does not seem to be interested in speaking with you.")
        elseif answer == "wingless status" then
            add_dialogue("He stares at you for a moment.~~\"To be right, human.~~ \"To feel I am treated less for an absence of wings. To see Quaeven treated better since joining The Fellowship. To be devoted to the altar of singularity. But, perhaps to change if The Fellowship cares not about wings.\"")
            add_answer({"Quaeven", "treated"})
            remove_answer("wingless status")
        elseif answer == "Quaeven" then
            add_dialogue("\"To be also without wings, but to be respected as if he were winged.\"")
            remove_answer("Quaeven")
        elseif answer == "treated" then
            add_dialogue("\"To see many others include him in many events from which I am excluded. To know others include him in many more decision-making councils, too.\"")
            remove_answer("treated")
            add_answer("others")
        elseif answer == "others" then
            add_dialogue("\"Gargoyles in The Fellowship.\"")
            remove_answer("others")
        elseif answer == "bye" then
            add_dialogue("\"To get back to work.\"*")
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