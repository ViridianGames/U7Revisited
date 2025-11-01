--- Best guess: Handles dialogue with Tavenor, an Emp in Yew, discussing Emp lifestyle (food, Silverleaf trees), their aversion to violence, and addressing human destruction of the forest, urging the player to stop cutting Silverleaf trees.
function npc_tavenor_0100(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if eventid == 1 then
        var_0000 = utility_unknown_1073(359, 359, 772, 1, 357) --- Guess: Checks item in inventory
        switch_talk_to(100, 0)
        if not get_flag(340) then
            if not var_0000 then
                add_dialogue("The creature ignores you.")
                abort()
            end
            utility_unknown_1005() --- Guess: Interacts with Emp
        end
        if not get_flag(318) then
            if not get_flag(316) then
                add_dialogue("The ape-like creature in front of you approaches very cautiously. After a few minutes of staring you up and down, it cocks its head toward you.")
                add_dialogue("\"You are human.\"")
                set_flag(316, true)
            else
                add_dialogue("The Emp in front of you approaches very cautiously. After a few minutes of staring you up and down, he cocks his head towards you.")
                add_dialogue("\"You are human.\"")
            end
            set_flag(318, true)
        else
            add_dialogue("\"You are greeted by me, human.\" Tavenor slowly approaches.")
        end
        add_answer({"bye", "job", "name"})
        var_0001 = false
        while true do
            var_0002 = get_answer()
            if var_0002 == "name" then
                add_dialogue("\"Tavenor is my name.\"")
                remove_answer("name")
            elseif var_0002 == "job" then
                if not get_flag(302) then
                    add_dialogue("\"The meaning of `job' is not understood.\"")
                    add_answer("explain job")
                else
                    add_dialogue("\"No job is had by me. Food is gathered by me and my family.\"")
                    add_answer("food")
                end
            elseif var_0002 == "explain job" then
                add_dialogue("\"`Job' now understood by me. No job is had by me. Food is gathered by me and my family.\" He watches you carefully. \"Your job is to cut down Silverleaf trees, yes?\"")
                set_flag(302, true)
                var_0002 = select_option()
                if var_0002 then
                    add_dialogue("\"That is as I expected. You are a menace. You are asked to stop, please.\" He turns away from you.")
                    abort()
                else
                    add_dialogue("\"The truth is known to me, but, belief is hard for me.\"")
                    var_0003 = npc_id_in_party(6) --- Guess: Checks player status
                    if var_0003 then
                        add_dialogue("*")
                        switch_talk_to(6, 0)
                        add_dialogue("\"The truth is spoken by the human,\" Trellek says to the other Emp. \"He is to be trusted. His good will was felt by me.\"")
                        hide_npc(6)
                        switch_talk_to(100, 0)
                        add_dialogue("The Emp nods at Trellek, and then turns to you. \"The truth is now clear to me. You are wished good luck.\"")
                    else
                        add_dialogue("The Emp eyes you a little longer. \"Your good intentions are known to me. You are asked to be the messenger. Humans will not be destroyers, please.\"")
                    end
                    remove_answer("explain job")
                    set_flag(302, true)
                end
                add_answer({"Silverleaf trees", "food"})
            elseif var_0002 == "food" then
                add_dialogue("\"Fruit and milk are Emp foods. Especially fruits are liked by me. Meats,\" he shakes his head,")
                add_dialogue("\"are -not- liked by Emps.\"")
                remove_answer("food")
                add_answer({"milk", "fruits", "meats"})
            elseif var_0002 == "milk" then
                add_dialogue("\"Milk is good. Milk with honey is preferred by me.\"")
                if not var_0001 then
                    add_answer("honey")
                end
                remove_answer("milk")
            elseif var_0002 == "Silverleaf trees" then
                add_dialogue("\"Silverleaf trees are Emp homes.\"")
                remove_answer("Silverleaf trees")
            elseif var_0002 == "meats" then
                add_dialogue("\"Meats are from killed animals. Killing is bad. Destroying is bad.\"")
                remove_answer("meats")
            elseif var_0002 == "fruits" then
                add_dialogue("\"Fruits are good and sweet -- like honey!\"")
                remove_answer("fruits")
                if not var_0001 then
                    add_answer("honey")
                end
            elseif var_0002 == "honey" then
                add_dialogue("\"Honey is favorite food of all Emps!\"")
                var_0001 = true
                remove_answer("honey")
            elseif var_0002 == "bye" then
                break
            end
        end
        add_dialogue("\"You are told `goodbye.'\"")
    elseif eventid == 0 then
        abort()
    end
end