require "U7LuaFuncs"
-- func_043C.lua
-- Mack's dialogue near Britain
local U7 = require("U7LuaFuncs")

function func_043C(eventid)
    local answers = {}
    local flag_00B3 = U7.getFlag(0x00B3) -- First meeting
    local flag_008A = U7.getFlag(0x008A) -- UFO topic
    local npc_id = -50 -- Mack's NPC ID

    if eventid == 1 then
        U7.SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Item interaction
        local var_0002 = U7.callExtern(0x092E, 2) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_008A then
            table.insert(answers, "UFO")
        end

        if not flag_00B3 then
            U7.say("You see a wiry farmer with wild eyes, clutching a turnip like it’s gold.")
            U7.setFlag(0x00B3, true)
        else
            U7.say("\"Back again, \" .. U7.getPlayerName() .. \"?\" Mack says, eyeing you suspiciously.")
        end

        while true do
            if #answers == 0 then
                U7.say("Mack scratches his head. \"What’s that? Got more questions?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Mack’s my name! Farmer, inventor, and truth-seeker!\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I farm turnips, best in Britannia! Also tinker with inventions. Made a contraption to scare crows, but it scares me too sometimes.\"")
                table.insert(answers, "turnips")
                table.insert(answers, "inventions")
            elseif choice == "turnips" then
                U7.say("\"My turnips are the finest! Big, juicy, and full of secrets. Want one? Only 3 gold!\"")
                table.insert(answers, "buy")
                U7.RemoveAnswer("turnips")
            elseif choice == "inventions" then
                U7.say("\"Got a plow-sharpening machine and a chicken feeder. But my pride’s the Great Hoe—cuts weeds like magic! Still working out the kinks, though.\"")
                table.insert(answers, "Great Hoe")
                U7.RemoveAnswer("inventions")
            elseif choice == "Great Hoe" then
                U7.say("\"It’s a marvel! Sharpens itself, but sometimes it wanders off. Found it in the barn once, hoeing by itself!\"")
                U7.RemoveAnswer("Great Hoe")
            elseif choice == "buy" then
                U7.say("\"A turnip for 3 gold. Deal?\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    local gold_result = U7.removeGold(3)
                    if gold_result then
                        local item_result = U7.giveItem(16, 1, 380)
                        if item_result then
                            U7.say("\"Here’s thy turnip! Guard it well!\"")
                        else
                            U7.say("\"Thou art too weighed down to carry this turnip!\"")
                        end
                    else
                        U7.say("\"No gold, no turnip. Come back when thou art richer!\"")
                    end
                else
                    U7.say("\"Suit thyself, but thou art missing out!\"")
                end
                U7.RemoveAnswer("buy")
            elseif choice == "UFO" then
                U7.say("\"Thou knowest about the lights in the sky? I saw one, big as a barn, hovering over my field! It left strange marks in the dirt. The turnips there grew twice as big!\"")
                table.insert(answers, "lights")
                table.insert(answers, "marks")
                U7.RemoveAnswer("UFO")
            elseif choice == "lights" then
                U7.say("\"Bright, pulsing lights, not like any star. Moved too fast to be a bird or balloon. I’m telling thee, it was no natural thing!\"")
                U7.RemoveAnswer("lights")
            elseif choice == "marks" then
                U7.say("\"Circles in the dirt, perfect as a compass. I keep ‘em hidden under hay. If thou findest a strange metal piece, bring it to me!\"")
                table.insert(answers, "metal piece")
                U7.RemoveAnswer("marks")
            elseif choice == "metal piece" then
                U7.say("\"A shiny bit, like no metal I’ve seen. If thou bringest me one, I’ll trade thee something special—maybe a turnip or two!\"")
                local item_check = U7.hasItem(16, 1, 381)
                if item_check then
                    local trade_result = U7.removeItem(16, 1, 381)
                    if trade_result then
                        local item_result = U7.giveItem(16, 2, 380)
                        if item_result then
                            U7.say("\"By the Virtues, thou found it! Here’s two turnips for thy trouble!\"")
                        else
                            U7.say("\"Thou canst not carry more turnips! Clear some space!\"")
                        end
                    end
                else
                    U7.say("\"No metal piece? Keep an eye out, friend!\"")
                end
                U7.RemoveAnswer("metal piece")
            elseif choice == "bye" then
                U7.say("\"Watch the skies, \" .. U7.getPlayerName() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_043C