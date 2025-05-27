--- Best guess: Manages Aurvidlem’s dialogue in Vesper, a gargoyle provisioner critical of Ansikart’s leadership and concerned about Wis-Sur’s change.
function func_04DB(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 219)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(664) then
            add_dialogue("The gargoyle standing before you has a sour expression on his face.")
            set_flag(664, true)
        else
            add_dialogue("\"To offer you greetings, human,\" says Aurvidlem.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be called Aurvidlem. To recognize you to be the Avatar.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"To provide provisions for others in Vesper.\"")
                add_answer({"Vesper", "others", "buy provisions"})
            elseif answer == "Vesper" then
                add_dialogue("\"To be a town filled with prejudice and hatred. To know the humans expect us to begin a violent confrontation.\"")
                add_dialogue("\"To believe the humans deserve it,\" he shrugs, \"but to hope my brethren display more control than that.\"")
                remove_answer("Vesper")
            elseif answer == "buy provisions" then
                var_0000 = unknown_001CH(get_npc_name(219))
                if var_0000 ~= 7 then
                    add_dialogue("\"To be not selling at this time. To come back tomorrow to buy provisions.\"")
                else
                    var_0001 = unknown_0028H(359, 359, 644, 357)
                    unknown_084CH()
                    var_0002 = unknown_0028H(359, 359, 644, 357)
                    if var_0001 - var_0002 > 29 then
                        set_flag(639, true)
                    end
                end
                remove_answer("buy provisions")
            elseif answer == "others" then
                if get_flag(639) then
                    add_dialogue("\"To have only a few gargoyles living in town. To know mainly Wis-Sur, and,\" he gives a slight grunt, \"Ansikart. Also to know of some wingless ones.\"")
                    add_answer("Ansikart")
                else
                    add_dialogue("\"To have only a few gargoyles living in town. To know mainly Wis-Sur and Ansikart, and to know of some wingless ones.\"")
                end
                remove_answer("others")
            elseif answer == "Ansikart" then
                add_dialogue("His eyes shift quickly from left to right before finally settling on you.")
                add_dialogue("\"To know since change in Wis-Sur, Ansikart gained too much respect. To be sure that I have studied more and would be a wiser and better leader here. To be dissatisfied with Ansikart as choice.\"")
                add_answer("change")
                remove_answer("Ansikart")
            elseif answer == "change" then
                add_dialogue("\"To be unsure when change happened, but has affected Wis-Sur greatly. To now see him avoid others and shut himself away. To be concerned for Wis-Sur.\"")
                remove_answer("change")
            elseif answer == "bye" then
                add_dialogue("\"To bid you goodbye.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092FH(219)
    end
    return
end