--- Best guess: Manages Zaksam’s dialogue in Vesper, a trainer wary of gargoyles and suspicious of certain residents like Blorn.
function func_04CD(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        switch_talk_to(0, 205)
        var_0000 = unknown_0908H()
        var_0001 = get_lord_or_lady()
        var_0002 = unknown_001CH(unknown_001BH(205))
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(650) then
            add_dialogue("A strong, powerful man looks at you and nods acknowledgment.")
        else
            add_dialogue("\"What can I do for thee?\" asks Zaksam.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Zaksam,\" he states proudly.")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I teach others to be strong fighters. I am a trainer here in Vesper.\"")
                add_answer({"train", "Vesper"})
            elseif answer == "Vesper" then
                add_dialogue("\"I have taught here for many years. I like the town, but I am not too fond of some of the residents.\"")
                add_answer({"residents", "town"})
                remove_answer("Vesper")
            elseif answer == "town" then
                add_dialogue("\"The land to the northeast is a bit dry, but the oasis and nearby shores give us plenty of water for drinking and bathing.\"")
                remove_answer("town")
            elseif answer == "residents" then
                add_dialogue("\"Most of us are respectable, but there are a few that I wonder about. Blorn and the mayor, for example.\"")
                add_answer({"Blorn", "mayor"})
                remove_answer("residents")
            elseif answer == "mayor" then
                add_dialogue("\"'Tis not that I do not trust him. I just wonder about his ability to run the town. His name is Auston. Talk to him and see for thyself what thou thinkest. Better yet, talk to his clerk, Liana.\"")
                remove_answer("mayor")
            elseif answer == "Blorn" then
                add_dialogue("\"That one I do not like a bit. I do not trust him. He reminds me of those gargoyles.\"")
                add_answer("gargoyles")
                remove_answer("Blorn")
            elseif answer == "gargoyles" then
                add_dialogue("\"What is there to say, but do not let them get too close or they will rob thee. Any day now they may try to use violence to take over the town. The mayor himself has asked that I fight if necessary. Though I have no fear of death, that is a battle I do not look forward to.\"")
                remove_answer("gargoyles")
                add_answer({"violence", "rob"})
            elseif answer == "rob" then
                add_dialogue("\"I have already heard that some of my fellow residents have had things stolen by those wretched creatures.\"")
                remove_answer("rob")
            elseif answer == "violence" then
                add_dialogue("\"As thou must surely know, all gargoyles are prone to senseless fits of violence. 'Twould be quite natural to expect them to use it for their own selfish gain.\"")
                remove_answer("violence")
            elseif answer == "train" then
                if var_0002 == 7 then
                    add_dialogue("\"I can train thee for 40 gold. Is this all right?\"")
                    if unknown_090AH() then
                        unknown_094FH(40, 4, 0)
                    else
                        add_dialogue("\"Perhaps next time, \" .. var_0001 .. \".\"")
                    end
                else
                    add_dialogue("\"I can train thee when I am at my training hall, \" .. var_0001 .. \". Please feel free to see me when it is open.\"")
                end
            elseif answer == "bye" then
                add_dialogue("\"May thy strength be thy guide.\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0002 = unknown_001CH(unknown_001BH(205))
        var_0003 = unknown_003BH()
        var_0004 = random(4, 1)
        if var_0002 == 14 and (var_0003 == 7 or var_0003 == 0 or var_0003 == 1) then
            var_0005 = "@Zzzzz . . .@"
        elseif var_0003 >= 2 and var_0003 <= 5 and var_0002 == 7 then
            if var_0004 == 1 then
                var_0005 = "@Increase thy skill here!@"
            elseif var_0004 == 2 then
                var_0005 = "@Increase thy strength here!@"
            elseif var_0004 == 3 then
                var_0005 = "@Fight better, be stronger!@"
            elseif var_0004 == 4 then
                var_0005 = "@Defend thyself against gargoyles!@"
            end
        elseif var_0003 == 6 and var_0002 == 26 then
            var_0005 = "@Mmmmm, excellent wine!@"
        end
        bark(var_0005, 205)
    end
    return
end