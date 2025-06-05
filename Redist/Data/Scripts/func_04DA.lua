--- Best guess: Manages Foranamo’s dialogue in Vesper, a hostile gargoyle who may attack the player due to resentment toward humans, often alongside Anmanivas.
function func_04DA(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000D, var_000E

    if eventid == 1 then
        switch_talk_to(0, 218)
        var_0000 = get_npc_name(218)
        var_0001 = get_npc_name(217)
        var_0002 = get_player_name()
        var_0003 = get_lord_or_lady()
        var_0004 = "the Avatar"
        var_0005 = unknown_003CH(var_0001)
        if var_0005 == 1 then
            add_dialogue("The gargoyle's anger is so great that he resists the spell.")
            unknown_003DH(2, var_0000)
            unknown_003DH(2, var_0001)
            return
        end
        var_0006 = unknown_001CH(var_0000)
        if var_0006 == 16 then
            start_conversation()
            add_answer({"bye", "job", "name"})
            add_dialogue("The gargoyle is obviously displeased with the intrusion of your presence.")
            while true do
                local answer = get_answer()
                if answer == "name" then
                    add_dialogue("\"To have no desire to tell you. To demand to know who you are!\"")
                    remove_answer("name")
                    var_0007 = unknown_090BH({var_0003, var_0004, var_0002})
                    if var_0007 == var_0004 then
                        var_0008 = 0
                        var_0009 = unknown_0023H()
                        for _ = 1, var_0009 do
                            var_0008 = var_0008 + 1
                        end
                        if var_0008 == 1 then
                            var_000D = "human"
                        else
                            var_000D = "humans"
                        end
                        add_dialogue("The gargoyle growls as he turns to look at you. He stands,")
                        var_000E = unknown_08F7H(217)
                        if not var_000E then
                            add_dialogue("setting a hand on the shoulder of the gargoyle next to him.")
                            switch_talk_to(0, 217)
                            add_dialogue("The other gargoyle also stands. Anger flashes across his face as he points a finger at you.")
                            add_dialogue("\"To be the cause for our unhappiness, \" .. var_000D .. \"!\"")
                            hide_npc(217)
                            switch_talk_to(0, 218)
                        end
                        add_dialogue("\"To be the reason for our poverty. To die, \" .. var_000D .. \", to die!\"")
                        unknown_001DH(0, var_0000)
                        unknown_001DH(0, var_0001)
                        unknown_003DH(2, var_0001)
                        unknown_003DH(2, var_0000)
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
            add_dialogue("The gargoyle stops only long enough to give you a menacing stare.")
            return
        end
    elseif eventid == 0 then
        return
    end
    return
end