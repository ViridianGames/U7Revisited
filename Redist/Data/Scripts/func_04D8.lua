-- Function 04D8: Wis-Sur's mage dialogue and paranoia
function func_04D8(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -216)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0295) then
        if not get_flag(0x0003) then
            say("You see a winged gargoyle with an authoritative disposition.")
        else
            say("The winged gargoyle in front of you has a wild look about him.")
        end
        set_flag(0x0295, true)
    else
        if not get_flag(0x0003) then
            say("\"To offer welcome for you, human,\" says Wis-Sur.")
        else
            say("\"To go away, human! To have nothing you want!\" screams Wis-Sur.")
        end
    end

    if get_flag(0x0003) then
        while true do
            local answer = wait_for_answer()

            if answer == "name" then
                say("\"To wonder why you want to know.\"*")
                return
            elseif answer == "job" then
                say("\"To sell the few items I possess.\"")
                _AddAnswer("sell")
            elseif answer == "sell" then
                say("\"To want to buy something?\" He looks at you carefully, as if he is unsure whether to sell to you.~~\"To be possible,\" he says, nodding. \"To ask what you need?\"")
                local0 = {"potions", "reagents", "spells", "nothing"}
                _AddAnswer(local0)
                local1 = call_090BH(local0)
                if local1 == "nothing" then
                    say("\"To suspect you are wasting my time!\"")
                elseif local1 == "spells" then
                    call_094CH()
                elseif local1 == "reagents" then
                    call_094AH()
                elseif local1 == "potions" then
                    call_0949H()
                end
                _RemoveAnswer({"potions", "reagents", "spells", "nothing"})
            elseif answer == "bye" then
                say("\"To be good that you leave.\"*")
                return
            end
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be named Wis-Sur, which means `wise sun.'\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"To sell magic to others.\"")
            _AddAnswer({"magic", "others"})
        elseif answer == "magic" then
            say("\"To be interested in spells, reagents, or potions?\"")
            _AddAnswer({"potions", "reagents", "spells"})
            _RemoveAnswer("magic")
        elseif answer == "spells" then
            call_094CH()
        elseif answer == "reagents" then
            call_094AH()
        elseif answer == "potions" then
            call_0949H()
        elseif answer == "others" then
            say("\"To be familiar with only the other gargoyles in Vesper. To tell you to ask Ansikart, who knows all other gargoyles here. To tell you about one of the following?\"")
            _AddAnswer({"Anmanivas", "For-Lem", "Lap-Lem", "Aurvidlem"})
            _RemoveAnswer("others")
        elseif answer == "Aurvidlem" then
            say("\"To be a provisioner in Vesper.\"")
            _RemoveAnswer("Aurvidlem")
        elseif answer == "For-Lem" then
            say("\"To perform assorted duties for town. To be a good, strong worker.\"")
            _RemoveAnswer("For-Lem")
        elseif answer == "Lap-Lem" then
            say("\"To be a miner for the Britannian Mining Company.\"")
            _RemoveAnswer("Lap-Lem")
        elseif answer == "Anmanivas" then
            say("\"To be a miner for the Britannian Mining Company.\"")
            _RemoveAnswer("Anmanivas")
        elseif answer == "bye" then
            say("\"To say farewell, human.\"*")
            return
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