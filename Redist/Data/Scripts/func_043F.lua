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
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Item interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00C8 then
            add_answer( "Kessler")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00B6 then
            add_dialogue("You see a gentle woman with worried eyes, tidying shelves of herbs and potions.")
            set_flag(0x00B6, true)
        else
            add_dialogue("\"Welcome back, \" .. U7.getPlayerName() .. \",\" Jesamine says softly.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Jesamine glances up. \"Is there more I can help thee with?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"I’m Jesamine, wife of Kessler, the apothecary.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I help my husband run the apothecary. I manage the shop while he mixes potions and tends to the sick.\"")
                add_answer( "apothecary")
                add_answer( "Kessler")
                set_flag(0x00C8, true)
            elseif choice == "apothecary" then
                add_dialogue("\"We sell herbs, potions, and remedies. Kessler’s skill is renowned, but I worry he works too hard.\"")
                add_answer( "remedies")
                add_answer( "works too hard")
                remove_answer("apothecary")
            elseif choice == "remedies" then
                add_dialogue("\"We’ve got healing salves, sleep draughts, and more. Need anything? A potion’s 15 gold.\"")
                add_answer( "buy")
                remove_answer("remedies")
            elseif choice == "works too hard" then
                add_dialogue("\"Kessler’s up all hours, brewing or visiting patients. He’s not been well himself, but he won’t rest.\"")
                add_answer( "not well")
                remove_answer("works too hard")
            elseif choice == "not well" then
                add_dialogue("\"He coughs at night and tires easily. I’ve tried giving him his own remedies, but he insists he’s fine. I fear for him.\"")
                remove_answer("not well")
            elseif choice == "Kessler" then
                add_dialogue("\"My husband is a good man, always helping others. But his health worries me, and he listens not to my pleas to slow down.\"")
                add_answer( "health")
                remove_answer("Kessler")
            elseif choice == "health" then
                add_dialogue("\"If thou knowest a healer or a way to ease his cough, I’d be forever grateful. I can’t lose him.\"")
                remove_answer("health")
            elseif choice == "buy" then
                add_dialogue("\"A potion for 15 gold. Wilt thou take one?\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    local gold_result = U7.removeGold(15)
                    if gold_result then
                        local item_result = U7.giveItem(16, 1, 384)
                        if item_result then
                            add_dialogue("\"Here’s a potion, crafted by Kessler himself.\"")
                        else
                            add_dialogue("\"Thou art too burdened to carry the potion!\"")
                        end
                    else
                        add_dialogue("\"Sorry, thou lackest the gold for a potion.\"")
                    end
                else
                    add_dialogue("\"Perhaps another time, then.\"")
                end
                remove_answer("buy")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship? They’ve offered Kessler help with the shop, but their aid comes with strings. I’d rather we stay independent.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Mayhap they mean well. I’ll consider their offer.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"No, I trust my instincts. We’ll manage without them.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Take care, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_043F