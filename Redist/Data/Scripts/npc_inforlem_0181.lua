--- Best guess: Manages Inforlem's dialogue in Terfin, a gargoyle trainer and weapon seller, discussing local conflicts and residents.
function npc_inforlem_0181(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        switch_talk_to(0, 181)
        var_0000 = false
        var_0001 = get_schedule()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(582) then
            add_dialogue("The gargoyle has a pleasant expression on his face.")
            set_flag(582, true)
        else
            add_dialogue("\"To be pleased at your return, human,\" says Inforlem.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be known as Inforlem.\"")
                remove_answer("name")
                add_answer("Inforlem")
            elseif answer == "Inforlem" then
                add_dialogue("\"To mean `make strong one.'\"")
                remove_answer("Inforlem")
            elseif answer == "job" then
                add_dialogue("\"To train others in Terfin to be strong and powerful. To sell some weapons, also.\"")
                add_answer({"buy", "Terfin", "others", "train"})
                if get_flag(580) and not var_0000 then
                    add_answer("conflicts")
                end
            elseif answer == "buy" then
                if var_0001 == 3 or var_0001 == 4 or var_0001 == 5 then
                    utility_shopweapons_0924()
                else
                    add_dialogue("\"To sell during shop hours. To ask you to come back to me at that time, please.\"")
                end
            elseif answer == "train" then
                if var_0001 == 3 or var_0001 == 4 or var_0001 == 5 then
                    add_dialogue("\"To be a better warrior or mage?\"")
                    add_answer({"mage", "warrior"})
                else
                    add_dialogue("\"To train during training hours. To ask you to come back to me at that time, please.\"")
                end
            elseif answer == "warrior" then
                add_dialogue("\"To charge 50 gold for each training session. To be all right?\"")
                if ask_yes_no() then
                    utility_unknown_0923(50, 4, 1, 0)
                else
                    add_dialogue("\"To apologize, but I must charge that amount!\"")
                end
            elseif answer == "mage" then
                add_dialogue("\"To charge 50 gold for each training session. To be acceptable?\"")
                if ask_yes_no() then
                    utility_unknown_0922(50, 2, 6)
                else
                    add_dialogue("\"To apologize, but I must charge that amount!\"")
                end
            elseif answer == "conflicts" then
                add_dialogue("\"To know of the conflicts between the altars and The Fellowship, but to have no information. To suggest you see Quan, The Fellowship leader here and ask him.\"")
                var_0000 = true
                set_flag(572, true)
                remove_answer("conflicts")
            elseif answer == "Terfin" then
                add_dialogue("\"To see there are troubles here, but to be unaware of the causes and solutions.\"")
                remove_answer("Terfin")
            elseif answer == "others" then
                add_dialogue("\"To tell you Forbrak knows much about Terfin and its residents, and,\" he says, \"about its conflicts.\"")
                remove_answer("others")
                add_answer("Forbrak")
                if not var_0000 then
                    add_answer("conflicts")
                end
            elseif answer == "Forbrak" then
                add_dialogue("\"To be the tavernkeeper.\"")
                remove_answer("Forbrak")
            elseif answer == "bye" then
                add_dialogue("\"To expect to see you again, human.\"")
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1071(181)
    end
    return
end