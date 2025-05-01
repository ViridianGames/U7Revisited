-- Function 04D8: Wis-Sur's mage dialogue and paranoia
function func_04D8(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(216, 0)
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0295) then
        if not get_flag(0x0003) then
            add_dialogue("You see a winged gargoyle with an authoritative disposition.")
        else
            add_dialogue("The winged gargoyle in front of you has a wild look about him.")
        end
        set_flag(0x0295, true)
    else
        if not get_flag(0x0003) then
            add_dialogue("\"To offer welcome for you, human,\" says Wis-Sur.")
        else
            add_dialogue("\"To go away, human! To have nothing you want!\" screams Wis-Sur.")
        end
    end

    if get_flag(0x0003) then
        while true do
            local answer = wait_for_answer()

            if answer == "name" then
                add_dialogue("\"To wonder why you want to know.\"*")
                return
            elseif answer == "job" then
                add_dialogue("\"To sell the few items I possess.\"")
                add_answer("sell")
            elseif answer == "sell" then
                add_dialogue("\"To want to buy something?\" He looks at you carefully, as if he is unsure whether to sell to you.~~\"To be possible,\" he says, nodding. \"To ask what you need?\"")
                local0 = {"potions", "reagents", "spells", "nothing"}
                add_answer(local0)
                local1 = call_090BH(local0)
                if local1 == "nothing" then
                    add_dialogue("\"To suspect you are wasting my time!\"")
                elseif local1 == "spells" then
                    call_094CH()
                elseif local1 == "reagents" then
                    call_094AH()
                elseif local1 == "potions" then
                    call_0949H()
                end
                remove_answer({"potions", "reagents", "spells", "nothing"})
            elseif answer == "bye" then
                add_dialogue("\"To be good that you leave.\"*")
                return
            end
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"To be named Wis-Sur, which means `wise sun.'\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"To sell magic to others.\"")
            add_answer({"magic", "others"})
        elseif answer == "magic" then
            add_dialogue("\"To be interested in spells, reagents, or potions?\"")
            add_answer({"potions", "reagents", "spells"})
            remove_answer("magic")
        elseif answer == "spells" then
            call_094CH()
        elseif answer == "reagents" then
            call_094AH()
        elseif answer == "potions" then
            call_0949H()
        elseif answer == "others" then
            add_dialogue("\"To be familiar with only the other gargoyles in Vesper. To tell you to ask Ansikart, who knows all other gargoyles here. To tell you about one of the following?\"")
            add_answer({"Anmanivas", "For-Lem", "Lap-Lem", "Aurvidlem"})
            remove_answer("others")
        elseif answer == "Aurvidlem" then
            add_dialogue("\"To be a provisioner in Vesper.\"")
            remove_answer("Aurvidlem")
        elseif answer == "For-Lem" then
            add_dialogue("\"To perform assorted duties for town. To be a good, strong worker.\"")
            remove_answer("For-Lem")
        elseif answer == "Lap-Lem" then
            add_dialogue("\"To be a miner for the Britannian Mining Company.\"")
            remove_answer("Lap-Lem")
        elseif answer == "Anmanivas" then
            add_dialogue("\"To be a miner for the Britannian Mining Company.\"")
            remove_answer("Anmanivas")
        elseif answer == "bye" then
            add_dialogue("\"To say farewell, human.\"*")
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