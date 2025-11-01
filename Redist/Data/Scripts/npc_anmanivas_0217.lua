--- Best guess: Manages Anmanivas's dialogue in Vesper, a hostile gargoyle who may attack the player due to resentment toward humans.
function npc_anmanivas_0217(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000D, var_000E, var_000F

    if eventid == 1 then
        switch_talk_to(217)
        var_0000 = get_npc_name(217)
        var_0001 = get_npc_name(218)
        var_0002 = get_player_name()
        var_0003 = get_lord_or_lady()
        var_0004 = "the Avatar"
        var_0005 = get_alignment(var_0000)
        if var_0005 == 1 then
            add_dialogue("The gargoyle's hatred is so bitter that he resists the spell.")
            set_alignment(2, var_0000)
            set_alignment(2, var_0001)
            return
        end
        var_0006 = get_schedule_type(var_0000)
        if var_0006 == 16 then
            start_conversation()
            add_answer({"bye", "job", "name"})
            add_dialogue("The gargoyle stares at you, displeased at the interruption.")
            while true do
                local answer = get_answer()
                if answer == "name" then
                    add_dialogue("\"To have no desire to tell you. To demand to know who you are!\"")
                    remove_answer("name")
                    var_0007 = utility_unknown_1035({var_0003, var_0004, var_0002})
                    if var_0007 == var_0004 then
                        add_dialogue("As the gargoyle looks up at you, anger crosses his face. He stands quickly, overturning his drink.")
                        var_0008 = 0
                        var_0009 = get_party_list()
                        for _ = 1, var_0009 do
                            var_0008 = var_0008 + 1
                        end
                        if var_0008 == 1 then
                            var_000D = "human"
                            var_000E = " he says, pointing at you."
                        else
                            var_000D = "humans"
                            var_000E = " he says, pointing at you and your companions."
                        end
                        add_dialogue("\"^\" .. var_000D .. \"!\" .. var_000E .. \" \"To be the cause for our unhappiness.\"")
                        var_000F = npc_id_in_party(218)
                        if not var_000F then
                            switch_talk_to(218)
                            add_dialogue("The gargoyle by his side also rises.")
                            add_dialogue("\"To be the reason for our poverty. To die, \" .. var_000D .. \", to die!\"")
                            hide_npc(218)
                            switch_talk_to(217)
                            add_dialogue("The two gargoyles force the table from their path with ease as they charge to attack you.")
                        else
                            add_dialogue("He forces the table from his path with ease as he charges to attack you.")
                        end
                        set_schedule_type(0, var_0000)
                        set_schedule_type(0, var_0001)
                        set_alignment(2, var_0000)
                        set_alignment(2, var_0001)
                        return
                    else
                        add_dialogue("\"To tell you to go away!\"")
                        return
                    end
                elseif answer == "job" then
                    add_dialogue("\"To have none!\" He glares fiercely at you.")
                    remove_answer("job")
                elseif answer == "bye" then
                    add_dialogue("He grunts his dismissal.")
                    return
                end
            end
        else
            add_dialogue("Though he glares as he passes, the gargoyle seems much too intent on reaching his destination to bother with you.")
            return
        end
    elseif eventid == 0 then
        return
    end
    return
end