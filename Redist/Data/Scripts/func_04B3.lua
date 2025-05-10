--- Best guess: Manages Polly’s dialogue in Paws, the bartender at the Salty Dog, offering rooms and discussing local residents and the venom theft.
function func_04B3(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid == 1 then
        switch_talk_to(0, 179)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_003BH()
        var_0002 = unknown_001CH(unknown_001BH(179))
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(530) then
            add_answer("thief")
        end
        if get_flag(536) then
            remove_answer("thief")
        end
        if get_flag(533) then
            add_answer("Merrick")
        end
        if get_flag(532) then
            add_answer("Morfin")
        end
        if get_flag(534) then
            add_answer("Thurston")
        end
        if not get_flag(556) then
            add_dialogue("You see the town bartender. She looks very busy, but she obviously takes pride in her work.")
            set_flag(556, true)
        else
            add_dialogue("Polly smiles. \"What can I do for thee, " .. var_0000 .. "?\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Polly. It is a pleasure to meet thee.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"The owner and proprietor of the Salty Dog, the finest eating and drinking establishment in all of Paws, at thy service.\"")
                if var_0002 == 23 then
                    add_answer({"room", "buy", "Paws"})
                else
                    add_dialogue("\"However, the Salty Dog is now closed. Please return during business hours.\"")
                    add_answer("Paws")
                end
            elseif answer == "buy" then
                unknown_08CDH()
                remove_answer("buy")
            elseif answer == "room" then
                add_dialogue("\"For but 5 gold thou canst let one of our lovely rooms. Dost thou wish to stay here for the night?\"")
                if unknown_090AH() then
                    var_0003 = unknown_0023H()
                    var_0004 = 0
                    for i = 1, var_0003 do
                        var_0004 = var_0004 + 1
                    end
                    var_0008 = var_0004 * 5
                    var_0009 = unknown_0028H(359, 644, 357)
                    if var_0009 >= var_0008 then
                        var_000A = unknown_002CH(true, 255, 641, 1)
                        if var_000A then
                            add_dialogue("\"Here is thy key for this inn. 'Twill only work once.\"")
                            var_000B = unknown_002BH(true, 359, 644, 359, var_0008)
                        else
                            add_dialogue("\"Sorry, " .. var_0000 .. ", thou must lose some of thy bundles before I can give thee thy key.\"")
                        end
                    else
                        add_dialogue("\"I am truly sorry, " .. var_0000 .. ", but the rooms cost more gold than thou hast.\"")
                    end
                else
                    add_dialogue("\"Perhaps another evening then.\"")
                end
                remove_answer("room")
            elseif answer == "Paws" then
                add_dialogue("\"Actually, there are no other inns or pubs in Paws. It is a small place, but our food and drink here is quite good, honestly.\"")
                remove_answer("Paws")
            elseif answer == "thief" then
                add_dialogue("\"There is a thief in this town! Silver serpent venom was stolen from Morfin, the merchant who operates the slaughterhouse.\"")
                set_flag(530, true)
                remove_answer("thief")
            elseif answer == "Merrick" then
                add_dialogue("\"He used to be a farmer. He is not a bad sort. He has just had a bad run of luck. Now he is a devout Fellowship member.\"")
                remove_answer("Merrick")
            elseif answer == "Morfin" then
                add_dialogue("\"Morfin is a very shrewd and successful merchant, and also a Fellowship member, but I cannot help but feel that he would sell his own mother if he could get the right price for her. 'Tis little wonder why the thief chose to steal from him.\"")
                add_answer("thief")
                remove_answer("Morfin")
            elseif answer == "Thurston" then
                add_dialogue("You relate to Polly what you heard Thurston say about her. She is taken completely by surprise. \"Thurston really said that about me! I have always liked him, but in truth I have always thought I was not good enough for him!\"")
                set_flag(539, true)
                remove_answer("Thurston")
            elseif answer == "bye" then
                add_dialogue("\"Good day to thee, " .. var_0000 .. ".\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(179)
    end
    return
end