-- func_043F.lua
-- Jesamine's dialogue as the apothecary's wife in Britain
local U7 = require("U7LuaFuncs")

function func_043F(eventid)
    local answers = {}
    local flag_00B6 = U7.getFlag(0x00B6) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00C8 = U7.getFlag(0x00C8) -- Kessler’s health topic
    local npc_id = -53 -- Jesamine's NPC ID

    if eventid == 1 then
        U7.SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Item interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00C8 then
            table.insert(answers, "Kessler")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00B6 then
            U7.say("You see a gentle woman with worried eyes, tidying shelves of herbs and potions.")
            U7.setFlag(0x00B6, true)
        else
            U7.say("\"Welcome back, \" .. U7.getPlayerName() .. \",\" Jesamine says softly.")
        end

        while true do
            if #answers == 0 then
                U7.say("Jesamine glances up. \"Is there more I can help thee with?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I’m Jesamine, wife of Kessler, the apothecary.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I help my husband run the apothecary. I manage the shop while he mixes potions and tends to the sick.\"")
                table.insert(answers, "apothecary")
                table.insert(answers, "Kessler")
                U7.setFlag(0x00C8, true)
            elseif choice == "apothecary" then
                U7.say("\"We sell herbs, potions, and remedies. Kessler’s skill is renowned, but I worry he works too hard.\"")
                table.insert(answers, "remedies")
                table.insert(answers, "works too hard")
                U7.RemoveAnswer("apothecary")
            elseif choice == "remedies" then
                U7.say("\"We’ve got healing salves, sleep draughts, and more. Need anything? A potion’s 15 gold.\"")
                table.insert(answers, "buy")
                U7.RemoveAnswer("remedies")
            elseif choice == "works too hard" then
                U7.say("\"Kessler’s up all hours, brewing or visiting patients. He’s not been well himself, but he won’t rest.\"")
                table.insert(answers, "not well")
                U7.RemoveAnswer("works too hard")
            elseif choice == "not well" then
                U7.say("\"He coughs at night and tires easily. I’ve tried giving him his own remedies, but he insists he’s fine. I fear for him.\"")
                U7.RemoveAnswer("not well")
            elseif choice == "Kessler" then
                U7.say("\"My husband is a good man, always helping others. But his health worries me, and he listens not to my pleas to slow down.\"")
                table.insert(answers, "health")
                U7.RemoveAnswer("Kessler")
            elseif choice == "health" then
                U7.say("\"If thou knowest a healer or a way to ease his cough, I’d be forever grateful. I can’t lose him.\"")
                U7.RemoveAnswer("health")
            elseif choice == "buy" then
                U7.say("\"A potion for 15 gold. Wilt thou take one?\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    local gold_result = U7.removeGold(15)
                    if gold_result then
                        local item_result = U7.giveItem(16, 1, 384)
                        if item_result then
                            U7.say("\"Here’s a potion, crafted by Kessler himself.\"")
                        else
                            U7.say("\"Thou art too burdened to carry the potion!\"")
                        end
                    else
                        U7.say("\"Sorry, thou lackest the gold for a potion.\"")
                    end
                else
                    U7.say("\"Perhaps another time, then.\"")
                end
                U7.RemoveAnswer("buy")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship? They’ve offered Kessler help with the shop, but their aid comes with strings. I’d rather we stay independent.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Mayhap they mean well. I’ll consider their offer.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"No, I trust my instincts. We’ll manage without them.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Take care, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_043F