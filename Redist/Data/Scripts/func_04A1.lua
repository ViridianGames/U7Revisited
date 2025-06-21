--- Best guess: Manages Chad’s dialogue in Moonglow, offering light weapon training and town information, with humorous Avatar banter.
function func_04A1(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        switch_talk_to(0, 161)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = "Avatar"
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(497) then
            var_0003 = var_0000
        elseif not get_flag(499) then
            var_0003 = var_0002
        elseif not get_flag(498) then
            var_0003 = var_0001
        end
        if not get_flag(515) then
            add_dialogue("You see a lithe-looking fighter smile in your direction.")
        else
            add_dialogue("Chad smiles. \"Hello, " .. var_0003 .. ". I hope thy days are going well.\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Chad, at thy service, " .. var_0001 .. ". And what is thy name?\"")
                remove_answer("name")
                var_0004 = unknown_090BH(var_0001, var_0002, var_0000)
                if var_0004 == var_0000 then
                    add_dialogue("\"Greetings, " .. var_0000 .. ". I am at thy service.\"")
                    set_flag(497, true)
                elseif var_0004 == var_0001 then
                    add_dialogue("\"Greetings, " .. var_0001 .. ".\" He shrugs.")
                    set_flag(498, true)
                elseif var_0004 == var_0002 then
                    add_dialogue("\"Of course, of course,\" he smiles. \"I should have realized that thou wert the Avatar. Why, it must have been, oh, at least, two weeks since thy last visit!\" He winks.")
                    var_0005 = npc_id_in_party(3)
                    switch_talk_to(0, 3)
                    add_dialogue("\"Thou art a fool! Cannot thy feeble eyes see this is the Avatar?\"")
                    hide_npc(3)
                    switch_talk_to(0, 161)
                    add_dialogue("\"Yes, yes! I can see that,\" he laughs. \"Then I must be Iolo!\"")
                    var_0006 = npc_id_in_party(-1)
                    switch_talk_to(0, 3)
                    if var_0006 then
                        add_dialogue("\"No, rogue! He is Iolo!\" He nods to Iolo. \"Thou... art a blind idiot!\"")
                    else
                        add_dialogue("\"No, rogue, thou art a blind idiot!\"")
                    end
                    hide_npc(3)
                    switch_talk_to(0, 161)
                    set_flag(499, true)
                end
                set_flag(515, true)
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I teach expertise with light weapons here in Moonglow.\"")
                add_answer({"Moonglow", "train"})
            elseif answer == "Moonglow" then
                add_dialogue("\"Dost thou want the location of the city or to know about the townspeople?\"")
                add_answer({"townspeople", "location"})
                remove_answer("Moonglow")
            elseif answer == "location" then
                add_dialogue("\"Moonglow is on an island directly east of the border between Britain and Paws.\"")
                remove_answer("location")
            elseif answer == "townspeople" then
                add_dialogue("\"The person to ask for that information would be Phearcy, the bartender. All I know are other bar patrons: Tolemac and Morz, two farmers.\"")
                remove_answer("townspeople")
            elseif answer == "train" then
                var_0007 = get_schedule()
                if var_0007 == 6 or var_0007 == 7 then
                    add_dialogue("\"Yes, I train people. But only during the day. Now, 'tis time for drink!\"")
                else
                    add_dialogue("\"Wilt thou pay the 45 gold for the training session?\"")
                    if ask_yes_no() then
                        unknown_085FH(45, 4, {1})
                    else
                        add_dialogue("\"Well, mayhap next time thou wilt be willing.\"")
                    end
                end
            elseif answer == "bye" then
                add_dialogue("\"Remember, always keeps thy wits about and thy blade ready.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(161)
    end
    return
end