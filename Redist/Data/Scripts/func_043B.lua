-- func_043B.lua
-- Willy's dialogue at the bakery in Britain


function func_043B(eventid)
    local answers = {}
    local flag_0085 = get_flag(0x0085) -- Jeanette's affection
    local flag_00B2 = get_flag(0x00B2) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local npc_id = -49 -- Willy's NPC ID

    if eventid == 1 then
        switch_talk_to(npc_id, 0)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x08A2, 1) -- Buy interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_0085 then
            add_answer( "Jeanette")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00B2 then
            add_dialogue("You see a portly man covered in flour, his hands busy kneading dough.")
            set_flag(0x00B2, true)
        else
            add_dialogue("\"Welcome back, \" .. get_player_name() .. \"!\" Willy says with a grin.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Willy wipes his hands. \"Anything else I can do for thee?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Willy’s the name. Best baker in Britain!\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I run the bakery here. Fresh bread, rolls, and cakes every day. Care to buy some?\"")
                add_answer( "bakery")
                add_answer( "buy")
            elseif choice == "bakery" then
                add_dialogue("\"My bakery’s been in the family for generations. We use only the finest flour from Paws. The secret’s in the kneading, thou knowest.\"")
                add_answer( "flour")
                remove_answer("bakery")
            elseif choice == "flour" then
                add_dialogue("\"Comes straight from the mills in Paws. Costs a pretty penny, but it’s worth it for the quality.\"")
                remove_answer("flour")
            elseif choice == "buy" then
                add_dialogue("\"What’ll it be? A loaf of bread for 5 gold, or a cake for 10?\"")
                local response = call_extern(0x08A2, var_0001)
                if response == 0 then
                    local gold_choice = get_answer({"bread", "cake", "none"})
                    if gold_choice == "bread" then
                        local gold_result = U7.removeGold(5)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 378)
                            if item_result then
                                add_dialogue("\"Here’s a fresh loaf, hot from the oven!\"")
                            else
                                add_dialogue("\"Thou art carrying too much to take the bread!\"")
                            end
                        else
                            add_dialogue("\"Sorry, thou dost not have enough gold for a loaf.\"")
                        end
                    elseif gold_choice == "cake" then
                        local gold_result = U7.removeGold(10)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 379)
                            if item_result then
                                add_dialogue("\"A fine cake, perfect for a feast!\"")
                            else
                                add_dialogue("\"Thou art carrying too much to take the cake!\"")
                            end
                        else
                            add_dialogue("\"Sorry, thou dost not have enough gold for a cake.\"")
                        end
                    else
                        add_dialogue("\"Changed thy mind? No matter.\"")
                    end
                else
                    add_dialogue("\"Maybe next time, then.\"")
                end
                remove_answer("buy")
            elseif choice == "Jeanette" then
                add_dialogue("\"Jeanette? From the Blue Boar? Why, she’s been makin’ eyes at me lately!\" He chuckles. \"Sweet lass, but I’m too busy with my dough to court her properly.\"")
                add_answer( "court")
                remove_answer("Jeanette")
            elseif choice == "court" then
                add_dialogue("\"I’d like to take her for a stroll, maybe share a loaf under the stars. But this bakery keeps me up to my elbows in flour all day!\"")
                remove_answer("court")
            elseif choice == "Fellowship" then
                add_dialogue("\"Aye, I’m a member of the Fellowship. They’ve been good to me, helped me get a loan to expand the bakery. Their philosophy’s all about hard work and trust.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou shouldst consider joining. It’s done wonders for my business!\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Not interested? Well, to each their own.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Come back soon for more fresh bread!\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_043B