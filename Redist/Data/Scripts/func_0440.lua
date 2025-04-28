require "U7LuaFuncs"
-- func_0440.lua
-- Kessler's dialogue as the apothecary in Britain
local U7 = require("U7LuaFuncs")

function func_0440(eventid)
    local answers = {}
    local flag_00B7 = U7.getFlag(0x00B7) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00C8 = U7.getFlag(0x00C8) -- Health topic
    local npc_id = -54 -- Kessler's NPC ID

    if eventid == 1 then
        U7.SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x08A3, 1) -- Buy interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00C8 then
            table.insert(answers, "health")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00B7 then
            U7.say("You see a thin man with tired eyes, surrounded by vials and herbs, coughing softly.")
            U7.setFlag(0x00B7, true)
        else
            U7.say("\"Greetings, \" .. U7.getPlayerName() .. \",\" Kessler says, stifling a cough.")
        end

        while true do
            if #answers == 0 then
                U7.say("Kessler adjusts a vial. \"Need something else?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I’m Kessler, apothecary of Britain.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I craft potions and remedies for the sick. From fevers to wounds, I’ve something for most ailments. Need a potion?\"")
                table.insert(answers, "remedies")
                table.insert(answers, "buy")
                U7.setFlag(0x00C8, true)
            elseif choice == "remedies" then
                U7.say("\"My salves heal cuts, my draughts cure sleeplessness, and my tonics ease pain. Each is made with care, though some herbs are scarce now.\"")
                table.insert(answers, "herbs")
                U7.RemoveAnswer("remedies")
            elseif choice == "herbs" then
                U7.say("\"I source mandrake from Moonglow and ginseng from the Deep Forest, but supplies are tight. The Fellowship’s been buying up stocks, I hear.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("herbs")
            elseif choice == "buy" then
                U7.say("\"A healing potion’s 15 gold, a tonic’s 10. What’ll it be?\"")
                local response = U7.callExtern(0x08A3, var_0001)
                if response == 0 then
                    local item_choice = U7.getPlayerChoice({"potion", "tonic", "none"})
                    if item_choice == "potion" then
                        local gold_result = U7.removeGold(15)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 384)
                            if item_result then
                                U7.say("\"Here’s thy healing potion. Use it wisely.\"")
                            else
                                U7.say("\"Thou canst not carry the potion! Lighten thy load.\"")
                            end
                        else
                            U7.say("\"Thou lackest the gold for a potion.\"")
                        end
                    elseif item_choice == "tonic" then
                        local gold_result = U7.removeGold(10)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 385)
                            if item_result then
                                U7.say("\"Here’s a tonic to ease thy pains.\"")
                            else
                                U7.say("\"Thou canst not carry the tonic! Lighten thy load.\"")
                            end
                        else
                            U7.say("\"Thou lackest the gold for a tonic.\"")
                        end
                    else
                        U7.say("\"Changed thy mind? Fair enough.\"")
                    end
                else
                    U7.say("\"Come back when thou art ready.\"")
                end
                U7.RemoveAnswer("buy")
            elseif choice == "health" then
                U7.say("\"Jesamine worries, but it’s just a cough. Been mixing potions too long, breathing in fumes. I’ll be fine, though I could use a better remedy.\"")
                table.insert(answers, "remedy")
                U7.RemoveAnswer("health")
            elseif choice == "remedy" then
                U7.say("\"If thou knowest a healer or a rare herb—like nightshade from Skara Brae—I’d pay well. My own stocks are low.\"")
                local item_check = U7.hasItem(16, 1, 386)
                if item_check then
                    local trade_result = U7.removeItem(16, 1, 386)
                    if trade_result then
                        local gold_result = U7.giveGold(50)
                        if gold_result then
                            U7.say("\"Nightshade! Thou’rt a lifesaver! Here’s 50 gold for thy trouble.\"")
                        else
                            U7.say("\"I’d pay thee, but thy purse is too full!\"")
                        end
                    end
                else
                    U7.say("\"No nightshade? If thou findest some, bring it to me.\"")
                end
                U7.RemoveAnswer("remedy")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s been sniffing around, offering to fund my shop. But I’ve heard they expect loyalty in return. I’d rather keep my freedom.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Perhaps they’re not so bad. I’ll hear them out.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Nay, I’ll stay clear. Too many strings attached.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Stay healthy, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0440