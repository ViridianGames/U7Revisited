--- Best guess: Manages Wis-Sur’s dialogue in Vesper, a paranoid gargoyle mage selling magical items, distrustful of humans.
function func_04D8(eventid, itemref)
    local var_0000, var_0001

    if eventid == 1 then
        switch_talk_to(0, 216)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(661) then
            if not get_flag(3) then
                add_dialogue("You see a winged gargoyle with an authoritative disposition.")
            else
                add_dialogue("The winged gargoyle in front of you has a wild look about him.")
            end
            set_flag(661, true)
        else
            if get_flag(3) then
                add_dialogue("\"To go away, human! To have nothing you want!\" screams Wis-Sur.")
            else
                add_dialogue("\"To offer welcome for you, human,\" says Wis-Sur.")
            end
        end
        if get_flag(3) then
            while true do
                local answer = get_answer()
                if answer == "name" then
                    add_dialogue("\"To wonder why you want to know.\"")
                    return
                elseif answer == "job" then
                    add_dialogue("\"To sell the few items I possess.\"")
                    add_answer("sell")
                elseif answer == "sell" then
                    add_dialogue("\"To want to buy something?\" He looks at you carefully, as if he is unsure whether to sell to you.")
                    add_dialogue("\"To be possible,\" he says, nodding. \"To ask what you need?\"")
                    var_0000 = {"potions", "reagents", "spells", "nothing"}
                    var_0001 = unknown_090BH(var_0000)
                    if var_0001 == "nothing" then
                        add_dialogue("\"To suspect you are wasting my time!\"")
                    elseif var_0001 == "spells" then
                        unknown_094CH()
                    elseif var_0001 == "reagents" then
                        unknown_094AH()
                    elseif var_0001 == "potions" then
                        unknown_0949H()
                    end
                elseif answer == "bye" then
                    add_dialogue("\"To be good that you leave.\"")
                    return
                end
            end
        else
            while true do
                local answer = get_answer()
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
                    unknown_094CH()
                elseif answer == "reagents" then
                    unknown_094AH()
                elseif answer == "potions" then
                    unknown_0949H()
                elseif answer == "others" then
                    add_dialogue("\"To be familiar with only the other gargoyles in Vesper. To tell you to ask Ansikart, who knows all other gargoyles here. To tell you about one of the following?\"")
                    remove_answer("others")
                    add_answer({"Anmanivas", "For-Lem", "Lap-Lem", "Aurvidlem"})
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
                    add_dialogue("\"To say farewell, human.\"")
                    break
                end
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end