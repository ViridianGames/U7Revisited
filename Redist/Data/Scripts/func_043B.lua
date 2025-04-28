require "U7LuaFuncs"
-- func_043B.lua
-- Willy's dialogue at the bakery in Britain
local U7 = require("U7LuaFuncs")

function func_043B(eventid)
    local answers = {}
    local flag_0085 = U7.getFlag(0x0085) -- Jeanette's affection
    local flag_00B2 = U7.getFlag(0x00B2) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local npc_id = -49 -- Willy's NPC ID

    if eventid == 1 then
        U7.SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x08A2, 1) -- Buy interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_0085 then
            table.insert(answers, "Jeanette")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00B2 then
            U7.say("You see a portly man covered in flour, his hands busy kneading dough.")
            U7.setFlag(0x00B2, true)
        else
            U7.say("\"Welcome back, \" .. U7.getPlayerName() .. \"!\" Willy says with a grin.")
        end

        while true do
            if #answers == 0 then
                U7.say("Willy wipes his hands. \"Anything else I can do for thee?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Willy’s the name. Best baker in Britain!\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I run the bakery here. Fresh bread, rolls, and cakes every day. Care to buy some?\"")
                table.insert(answers, "bakery")
                table.insert(answers, "buy")
            elseif choice == "bakery" then
                U7.say("\"My bakery’s been in the family for generations. We use only the finest flour from Paws. The secret’s in the kneading, thou knowest.\"")
                table.insert(answers, "flour")
                U7.RemoveAnswer("bakery")
            elseif choice == "flour" then
                U7.say("\"Comes straight from the mills in Paws. Costs a pretty penny, but it’s worth it for the quality.\"")
                U7.RemoveAnswer("flour")
            elseif choice == "buy" then
                U7.say("\"What’ll it be? A loaf of bread for 5 gold, or a cake for 10?\"")
                local response = U7.callExtern(0x08A2, var_0001)
                if response == 0 then
                    local gold_choice = U7.getPlayerChoice({"bread", "cake", "none"})
                    if gold_choice == "bread" then
                        local gold_result = U7.removeGold(5)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 378)
                            if item_result then
                                U7.say("\"Here’s a fresh loaf, hot from the oven!\"")
                            else
                                U7.say("\"Thou art carrying too much to take the bread!\"")
                            end
                        else
                            U7.say("\"Sorry, thou dost not have enough gold for a loaf.\"")
                        end
                    elseif gold_choice == "cake" then
                        local gold_result = U7.removeGold(10)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 379)
                            if item_result then
                                U7.say("\"A fine cake, perfect for a feast!\"")
                            else
                                U7.say("\"Thou art carrying too much to take the cake!\"")
                            end
                        else
                            U7.say("\"Sorry, thou dost not have enough gold for a cake.\"")
                        end
                    else
                        U7.say("\"Changed thy mind? No matter.\"")
                    end
                else
                    U7.say("\"Maybe next time, then.\"")
                end
                U7.RemoveAnswer("buy")
            elseif choice == "Jeanette" then
                U7.say("\"Jeanette? From the Blue Boar? Why, she’s been makin’ eyes at me lately!\" He chuckles. \"Sweet lass, but I’m too busy with my dough to court her properly.\"")
                table.insert(answers, "court")
                U7.RemoveAnswer("Jeanette")
            elseif choice == "court" then
                U7.say("\"I’d like to take her for a stroll, maybe share a loaf under the stars. But this bakery keeps me up to my elbows in flour all day!\"")
                U7.RemoveAnswer("court")
            elseif choice == "Fellowship" then
                U7.say("\"Aye, I’m a member of the Fellowship. They’ve been good to me, helped me get a loan to expand the bakery. Their philosophy’s all about hard work and trust.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou shouldst consider joining. It’s done wonders for my business!\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Not interested? Well, to each their own.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Come back soon for more fresh bread!\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_043B