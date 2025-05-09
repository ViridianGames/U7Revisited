--- Best guess: Manages an Emp NPC’s dialogue, greeting the player, discussing food preferences (fruits, milk, cheese), and handling honey offers, with gender-specific names.
function func_01DF(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006
    local var_0007, var_0008, var_0009

    if eventid == 1 then
        -- call [0000] (0931H, unmapped)
        var_0000 = unknown_0931H(359, 359, 772, 1, 357)
        switch_talk_to(0, 283)
        if get_flag(340) ~= true then
            if not var_0000 then
                start_conversation()
                add_dialogue("The creature ignores you.")
                return
            else
                -- call [0001] (087CH, unmapped)
                unknown_087CH()
            end
            start_conversation()
            if get_flag(316) ~= true then
                add_dialogue("The ape-like creature approaches you cautiously. After a few minutes, it says, \"You are greeted, human.\"")
                set_flag(316, true)
            else
                add_dialogue("The emp approaches you cautiously. After a few minutes, it says, \"You are greeted, human.\"")
            end
            add_dialogue("\"Is more honey had by you?\" The Emp asks hopefully.")
            -- call [0002] (090AH, unmapped)
            var_0001 = unknown_090AH()
            if not var_0001 then
                if var_0000 then
                    -- call [0001] (087CH, unmapped)
                    unknown_087CH()
                else
                    add_dialogue("\"No honey is had by you,\" says the Emp, obviously disappointed.")
                end
            else
                add_dialogue("Obviously disappointed, the Emp says, \"That is too bad. What is your wish?\"")
            end
            add_answer({"bye", "job", "name"})
            while true do
                start_conversation()
                local answer = get_answer()
                if answer == "name" then
                    var_0002 = get_npc_property(itemref, 5)
                    var_0003 = {1, 2, 3, 4}
                    if not is_in_int_array(var_0002, var_0003) then
                        var_0004 = check_flag_location(4, 80, 479, 356)
                        while true do
                            var_0005 = var_0004
                            var_0006 = var_0005
                            var_0007 = var_0006
                            var_0008 = get_npc_property(itemref, 5)
                            if is_in_int_array(var_0008, var_0003) then
                                var_0003 = unknown_093CH(var_0003, var_0008)
                            end
                            if var_0003 then
                                var_0002 = random2(4, 1)
                                if not is_in_int_array(var_0002, var_0003) then
                                    break
                                end
                            end
                        end
                        if var_0002 == 1 then
                            add_dialogue("\"Terandan is my name.\"")
                            var_0009 = "he"
                        elseif var_0002 == 2 then
                            add_dialogue("\"Sendala is my name.\"")
                            var_0009 = "she"
                        elseif var_0002 == 3 then
                            add_dialogue("\"Tvellum is my name.\"")
                            var_0009 = "he"
                        elseif var_0002 == 4 then
                            add_dialogue("\"Simrek is my name.\"")
                            var_0009 = "she"
                        end
                        remove_answer("name")
                    end
                elseif answer == "job" then
                    add_dialogue("\"No job is had by me. Food is gathered by me.\"")
                    add_answer("food")
                elseif answer == "food" then
                    add_dialogue("\"Fruit, milk, cheese are eaten by Emps.")
                    add_answer({"cheese", "milk", "fruits"})
                elseif answer == "milk" or answer == "cheese" then
                    add_dialogue("\"Cheese and milk are liked by Emps, but they are hard to find. Only from humans can these foods be found.\"")
                    remove_answer({"milk", "cheese"})
                elseif answer == "fruits" then
                    add_dialogue("\"Fruits are found easily in the forest,\" " .. var_0009 .. " says. \"They are what Emps use as food most often.\"")
                elseif answer == "bye" then
                    add_dialogue("\"Farewell is said to you.\"")
                    break
                end
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end