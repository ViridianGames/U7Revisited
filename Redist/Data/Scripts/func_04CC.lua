--- Best guess: Manages Mara’s dialogue in Vesper, a miner expressing strong distrust of gargoyles and concerns about town safety.
function func_04CC(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        switch_talk_to(0, 204)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_0908H()
        var_0002 = "the Avatar"
        var_0003 = unknown_001BH(204)
        var_0004 = unknown_001BH(203)
        var_0005 = unknown_003BH()
        var_0006 = unknown_001CH(var_0003)
        var_0007 = unknown_003CH(var_0003)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if var_0007 == 2 then
            unknown_001DH(0, var_0003)
            unknown_001DH(0, var_0004)
        end
        if not get_flag(649) then
            add_dialogue("You see a well-muscled woman who lifts her head in acknowledgement of your presence.")
            set_flag(649, true)
        else
            add_dialogue("\"Yes, \" .. var_0000 .. \"?\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("The woman grabs your hand and shakes vigorously. \"Hello. M'name's Mara.\"")
                if var_0006 == 26 then
                    add_dialogue("\"What is thine?\"")
                    var_0008 = unknown_090BH({var_0000, var_0002, var_0001})
                    if var_0008 == var_0002 then
                        add_dialogue("\"The Avatar!\" she shouts angrily. \"Why thou art the one responsible for bringing those wretched gargoyles into our fine land!\"")
                        unknown_001DH(0, var_0003)
                        unknown_003DH(2, var_0003)
                        unknown_001DH(0, var_0004)
                        unknown_003DH(2, var_0004)
                        return
                    else
                        add_dialogue("\"'Tis good to meet thee!\"")
                    end
                end
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("She flexes proudly, \"I am a miner in Vesper.\"")
                add_answer("Vesper")
            elseif answer == "Vesper" then
                add_dialogue("\"This used to be a pleasant town,\" she looks around, apparently checking if anyone is near, \"'til the gargoyles became so unruly. Now most of us have to spend far too much time wondering when the gargoyles will decide they want to kill us.\"")
                add_answer({"us", "gargoyles"})
                remove_answer("Vesper")
            elseif answer == "gargoyles" then
                add_dialogue("She shrugs. \"There is naught to say, except that they are a menace. This town would be a much better place without them.\"")
                remove_answer("gargoyles")
            elseif answer == "us" then
                add_dialogue("\"Well, I know Cador feels as I do, as does his wife. I have heard the mayor express his concern about them. I don't really know his clerk, Liana.\"")
                add_answer({"Liana", "mayor", "wife", "Cador"})
                remove_answer("us")
            elseif answer == "wife" then
                add_dialogue("\"Yvella is a lovely woman. She spends her days caring for their daughter, Catherine.\"")
                remove_answer("wife")
            elseif answer == "Liana" then
                add_dialogue("\"I have only seen her a few times. I do not know her well enough to say this, but I think she is angry about something, for she is always in a bad mood.\"")
                remove_answer("Liana")
            elseif answer == "Cador" then
                add_dialogue("\"He is in charge of managing the mines. Does a fair job, too. He usually joins me at the Gilded Lizard.\"")
                add_answer("Gilded Lizard")
                remove_answer("Cador")
            elseif answer == "mayor" then
                add_dialogue("\"His name is Auston. I like him, but I suspect that Liana is the one who truly keeps Vesper in order.\"")
                remove_answer("mayor")
            elseif answer == "Gilded Lizard" then
                add_dialogue("\"That is the tavern here in Vesper. Yongi's the barkeeper. He serves a passing fair tankard of ale.\"")
                remove_answer("Gilded Lizard")
            elseif answer == "bye" then
                add_dialogue("Mara shakes your hand and slaps you on the back, saying, \"Fare thee well, friend!\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(204)
    end
    return
end