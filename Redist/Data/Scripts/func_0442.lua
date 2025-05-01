-- func_0442.lua
-- Grayson's dialogue as the armorer in Britain
local U7 = require("U7LuaFuncs")

function func_0442(eventid)
    local answers = {}
    local flag_00B9 = U7.getFlag(0x00B9) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00CA = U7.getFlag(0x00CA) -- Crime topic
    local npc_id = -56 -- Grayson's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x08A5, 1) -- Buy interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00CA then
            table.insert(answers, "crime")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00B9 then
            U7.say("You see a broad-shouldered man polishing a gleaming breastplate.")
            U7.setFlag(0x00B9, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \"!\" Grayson says with a nod.")
        end

        while true do
            if #answers == 0 then
                U7.say("Grayson sets down his hammer. \"What else can I do for thee?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Grayson, armorer and weaponsmith.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I forge and sell weapons and armor. Swords, shields, plate—whatever keeps thee alive. Looking to buy?\"")
                table.insert(answers, "armor")
                table.insert(answers, "buy")
                U7.setFlag(0x00CA, true)
            elseif choice == "armor" then
                U7.say("\"My plate armor’s the best in Britain. Forged with steel from Minoc, tempered to take a beating. But crime’s been up, so folk need it more.\"")
                table.insert(answers, "crime")
                table.insert(answers, "Minoc")
                U7.RemoveAnswer("armor")
            elseif choice == "Minoc" then
                U7.say("\"Minoc’s mines produce fine steel. Costs a bit, but it’s worth it for gear that won’t fail in battle.\"")
                U7.RemoveAnswer("Minoc")
            elseif choice == "crime" then
                U7.say("\"Thieves and cutpurses are bolder these days. Word is, some are tied to the Fellowship, though I’ve no proof. Makes folk buy more armor, at least.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("crime")
            elseif choice == "buy" then
                U7.say("\"A sword’s 50 gold, a shield’s 30. What dost thou need?\"")
                local response = U7.callExtern(0x08A5, var_0001)
                if response == 0 then
                    local item_choice = U7.getPlayerChoice({"sword", "shield", "none"})
                    if item_choice == "sword" then
                        local gold_result = U7.removeGold(50)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 388)
                            if item_result then
                                U7.say("\"Here’s a fine sword, sharp and true.\"")
                            else
                                U7.say("\"Thou canst not carry the sword! Lighten thy load.\"")
                            end
                        else
                            U7.say("\"Thou lackest the gold for a sword.\"")
                        end
                    elseif item_choice == "shield" then
                        local gold_result = U7.removeGold(30)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 389)
                            if item_result then
                                U7.say("\"Here’s a sturdy shield to guard thee.\"")
                            else
                                U7.say("\"Thou canst not carry the shield! Lighten thy load.\"")
                            end
                        else
                            U7.say("\"Thou lackest the gold for a shield.\"")
                        end
                    else
                        U7.say("\"No purchase? Come back when thou’rt ready.\"")
                    end
                else
                    U7.say("\"Not today? My forge’ll still be here.\"")
                end
                U7.RemoveAnswer("buy")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s got a strong grip in Britain. They buy my gear in bulk, but I don’t like their secrecy. Something’s off about ‘em.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Maybe I’m too suspicious. I’ll keep an eye on ‘em.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Nay, I trust my gut. They’re trouble.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Stay sharp, \" .. U7.getPlayerName() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0442