--- Best guess: Manages Silamo’s dialogue in Terfin, a wingless gargoyle gardener frustrated by his social status and considering The Fellowship.
function func_04BB(eventid, objectref)
    if eventid == 1 then
        switch_talk_to(0, 187)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(588) then
            add_dialogue("You see a frowning gargoyle.")
            set_flag(588, true)
        else
            add_dialogue("\"To ask what you need, human,\" says Silamo.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be named `Silamo.'\"")
                if not get_flag(573) then
                    add_answer("wingless status")
                end
                remove_answer("name")
                add_answer("Silamo")
            elseif answer == "Silamo" then
                add_dialogue("\"To know my name if I were winged.\" He scowls at you.")
                remove_answer("Silamo")
            elseif answer == "job" then
                add_dialogue("\"To be the gardener,\" he shrugs, \"nothing more.\"")
                add_dialogue("He does not seem to be interested in speaking with you.")
            elseif answer == "wingless status" then
                add_dialogue("He stares at you for a moment.")
                add_dialogue("\"To be right, human.\"")
                add_dialogue("\"To feel I am treated less for an absence of wings. To see Quaeven treated better since joining The Fellowship. To be devoted to the altar of singularity. But, perhaps to change if The Fellowship cares not about wings.\"")
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
                add_dialogue("\"To get back to work.\"")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end