--- Best guess: Manages Yvella’s dialogue in Vesper, a concerned mother and Fellowship member worried about her daughter Catherine and distrustful of gargoyles.
function func_04D4(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid == 1 then
        switch_talk_to(0, 212)
        var_0000 = unknown_0908H()
        var_0001 = get_lord_or_lady()
        var_0002 = false
        var_0003 = unknown_0037H(get_npc_name(203))
        var_0004 = "the Avatar"
        start_conversation()
        add_answer({"bye", "Fellowship", "job", "name"})
        if get_flag(638) and not get_flag(645) then
            add_answer("Catherine at noon")
        end
        if get_flag(646) then
            var_0005 = var_0000
        elseif get_flag(647) then
            var_0005 = var_0001
        else
            var_0005 = var_0001
        end
        if not get_flag(657) then
            add_dialogue("The matronly woman you see has a look of concern on her face.")
            add_dialogue("\"Good day, \" .. var_0001 .. \". I am Yvella.\" She curtseys. \"Might I know thy name?\"")
            var_0006 = unknown_090BH({var_0004, var_0000})
            if var_0006 == var_0000 then
                add_dialogue("\"Pleased to meet thee, \" .. var_0000 .. \".\"")
                set_flag(646, true)
                var_0005 = var_0000
            elseif var_0006 == var_0004 then
                add_dialogue("\"Now, now, \" .. var_0001 .. \", thou shouldst not lie like that.\"")
                set_flag(647, true)
                var_0005 = var_0001
            end
            set_flag(657, true)
        else
            add_dialogue("\"Good day, \" .. var_0005 .. \".\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Yvella, \" .. var_0001 .. \".\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I take care of my daughter, Catherine, while Cador is at work.\"")
                if not var_0002 then
                    add_answer("Cador")
                end
                add_answer("Catherine")
            elseif answer == "Fellowship" then
                add_dialogue("\"Thou hast not heard of The Fellowship? It is a wonderful organization. They hold parades and festivals and have even built shelters for homeless folk throughout Britannia. Mine husband learned of them some time ago, and we have been happy members ever since.\"")
                if not var_0002 then
                    add_answer("husband")
                end
                remove_answer("Fellowship")
            elseif answer == "husband" or answer == "Cador" then
                if var_0003 then
                    add_dialogue("\"Cador was mine husband. He was the overseer at the Britannian Mining Company here in Vesper. I cannot believe he is gone,\" she sobs.")
                    add_dialogue("\"I told him again and again that tavern was a bad place to spend the evening. And now, he is dead, leaving me and Catherine without a husband and a father!\"")
                else
                    add_dialogue("\"Cador is mine husband. He is the overseer at the Britannian Mining Company here in Vesper.\"")
                    var_0007 = get_schedule()
                    if var_0007 == 6 or var_0007 == 7 then
                        add_dialogue("\"He is often at the tavern at this time. I do wish he would not go there every night with that... that... woman!\"")
                        add_answer("woman")
                    end
                end
                remove_answer({"husband", "Cador"})
                add_answer("Vesper")
                var_0002 = true
            elseif answer == "woman" then
                add_dialogue("\"Her name is Mara. She is a fellow miner. She is very nice, but also very beautiful. I do not like mine husband spending all that time with her.\"")
                remove_answer("woman")
            elseif answer == "Vesper" then
                add_dialogue("\"Well, it would be a lovely town if it were not for those... those... gargoyles. They are disgusting beings. I think Auston should have them run out of town.\"")
                add_answer({"gargoyles", "Auston"})
                remove_answer("Vesper")
            elseif answer == "Auston" then
                add_dialogue("\"He is our mayor. Eldroth recommended that we elect him, so, of course, we did. However, between the two of us, I think we ought to have someone new if Auston does not do something quickly. As a matter of fact, thou shouldst run for mayor, \" .. var_0001 .. \". What dost thou think? Wouldst thou like to run for mayor?\"")
                var_0008 = ask_yes_no()
                if var_0008 then
                    add_dialogue("\"I agree, thou ought to consider it.\"")
                else
                    add_dialogue("\"That is too bad. I believe thou wouldst be perfect for the office.\"")
                end
                add_answer("Eldroth")
                remove_answer("Auston")
            elseif answer == "Eldroth" then
                add_dialogue("\"He is our town advisor. Very wise man that Eldroth. He also sells provisions.\"")
                remove_answer("Eldroth")
            elseif answer == "gargoyles" then
                add_dialogue("\"Perfectly wretched beasts. Thank goodness most of them stay on their side of the oasis. I do not know how Cador stands working with them. Well, for him, that is. There is only one who still works there.\"")
                var_0009 = unknown_002CH(true, 359, 2, 797, 1)
                if var_0009 then
                    add_dialogue("\"Here,\" she says fumbling through her robes. Finally, she finds a piece of parchment and hands it to you.")
                end
                remove_answer("gargoyles")
            elseif answer == "Catherine" then
                add_dialogue("\"I worry about her. Every day at noon, she seems to disappear for a few hours. She has these foolish notions that gargoyles are friendly and honorable. I am afraid she may be visiting the other side of the oasis. Oh, I do hope not.\"")
                set_flag(638, true)
                remove_answer("Catherine")
            elseif answer == "Catherine at noon" then
                add_dialogue("\"Thou knowest where my daughter doth go at noon?\"")
                var_000A = ask_yes_no()
                if var_000A then
                    add_dialogue("\"Wilt thou tell me?\"")
                    var_000B = ask_yes_no()
                    if var_000B then
                        if not get_flag(637) then
                            add_dialogue("After you tell her, she responds, \"I knew it! That girl must be taught some sense. Associating with those vile creatures. Imagine!\" She shakes her head.")
                            if var_0003 then
                                add_dialogue("\"If only her father were here today, he would show that loathsome creature his place!\"")
                            else
                                add_dialogue("\"Just wait until I tell her father about this! He and Mara will certainly take care of the situation.!\"")
                                unknown_003FH(214)
                            end
                            add_dialogue("\"I thank thee, \" .. var_0005 .. \". I will put a stop to this right away!\"")
                            set_flag(645, true)
                            return
                        else
                            add_dialogue("After you tell her, she responds, \"I doubt that is true, \" .. var_0001 .. \", but I will look into the matter. I thank thee for thy concern.\"")
                        end
                    else
                        add_dialogue("\"Get thee away and cease taunting me! Thou art cruel, \" .. var_0005 .. \"!\"")
                        return
                    end
                else
                    add_dialogue("\"Oh, well. I thank thee for thy concern.\"")
                end
                remove_answer("Catherine at noon")
            elseif answer == "bye" then
                add_dialogue("\"Pleasant journey, \" .. var_0001 .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(212)
    end
    return
end