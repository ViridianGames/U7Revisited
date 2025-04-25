-- func_0443.lua
-- Clint's dialogue as the shipwright in Britain
local U7 = require("U7LuaFuncs")

function func_0443(eventid)
    local answers = {}
    local flag_00BA = U7.getFlag(0x00BA) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00CB = U7.getFlag(0x00CB) -- Ships topic
    local npc_id = -57 -- Clint's NPC ID

    if eventid == 1 then
        U7.SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x08A6, 1) -- Buy interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00CB then
            table.insert(answers, "ships")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00BA then
            U7.say("You see a weathered man with hands stained by pitch, inspecting a ship’s hull.")
            U7.setFlag(0x00BA, true)
        else
            U7.say("\"Ahoy, \" .. U7.getPlayerName() .. \"!\" Clint says with a wave.")
        end

        while true do
            if #answers == 0 then
                U7.say("Clint scratches his beard. \"Got more to discuss?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Clint, shipwright of Britain’s docks.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I build and repair ships for merchants and adventurers. Need a vessel or a deed? I’ve got both.\"")
                table.insert(answers, "ships")
                table.insert(answers, "buy")
                U7.setFlag(0x00CB, true)
            elseif choice == "ships" then
                U7.say("\"My ships are sturdy, built with timber from Yew. From small skiffs to galleons, they’ll carry thee across Britannia’s seas.\"")
                table.insert(answers, "timber")
                U7.RemoveAnswer("ships")
            elseif choice == "timber" then
                U7.say("\"Yew’s forests provide the best oak. Costs a fortune to ship it here, but no one’s drowned in a Clint-built vessel yet.\"")
                U7.RemoveAnswer("timber")
            elseif choice == "buy" then
                U7.say("\"A ship’s deed is 200 gold, a skiff’s 50. What’s thy fancy?\"")
                local response = U7.callExtern(0x08A6, var_0001)
                if response == 0 then
                    local item_choice = U7.getPlayerChoice({"ship", "skiff", "none"})
                    if item_choice == "ship" then
                        local gold_result = U7.removeGold(200)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 390)
                            if item_result then
                                U7.say("\"Here’s the deed to thy ship. She’s docked and ready!\"")
                            else
                                U7.say("\"Thou canst not carry the deed! Clear some space.\"")
                            end
                        else
                            U7.say("\"Thou lackest the gold for a ship.\"")
                        end
                    elseif item_choice == "skiff" then
                        local gold_result = U7.removeGold(50)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 391)
                            if item_result then
                                U7.say("\"Here’s the deed to thy skiff. Small but swift!\"")
                            else
                                U7.say("\"Thou canst not carry the deed! Clear some space.\"")
                            end
                        else
                            U7.say("\"Thou lackest the gold for a skiff.\"")
                        end
                    else
                        U7.say("\"No sale? Come back when thou’rt ready to sail.\"")
                    end
                else
                    U7.say("\"Not sailing today? My docks are always open.\"")
                end
                U7.RemoveAnswer("buy")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s been buying ships, claiming they’re for ‘spreading unity.’ But I’ve seen their crews—look more like mercenaries than missionaries.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Maybe they’re just traders. I’ll keep watch.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say(\"Nay, something’s fishy. I don’t trust ‘em.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Fair winds, \" .. U7.getPlayerName() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0443