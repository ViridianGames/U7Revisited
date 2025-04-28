require "U7LuaFuncs"
-- func_044E.lua
-- Chuckles's dialogue as the court jester in Castle British
local U7 = require("U7LuaFuncs")

function func_044E(eventid)
    local answers = {}
    local flag_00C4 = U7.getFlag(0x00C4) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D3 = U7.getFlag(0x00D3) -- Jests topic
    local npc_id = -67 -- Chuckles's NPC ID

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
        if flag_00D3 then
            table.insert(answers, "jests")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C4 then
            U7.say("You see a wiry man in motley, juggling apples with a mischievous grin.")
            U7.setFlag(0x00C4, true)
        else
            U7.say("\"Ho, \" .. U7.getPlayerName() .. \"!\" Chuckles cackles, tossing an apple.")
        end

        while true do
            if #answers == 0 then
                U7.say("Chuckles spins a coin. \"What’s thy jest, friend?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Chuckles I be, jester to Lord British’s court!\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I juggle, jest, and jape to keep the castle merry! My quips lighten hearts, but I hear whispers darker than my riddles.\"")
                table.insert(answers, "jests")
                table.insert(answers, "whispers")
                U7.setFlag(0x00D3, true)
            elseif choice == "jests" then
                U7.say("\"Here’s a riddle: what group speaks of unity but hides in shadows? Answer’s the Fellowship, methinks! Want another?\"")
                table.insert(answers, "Fellowship")
                table.insert(answers, "riddle")
                U7.RemoveAnswer("jests")
            elseif choice == "riddle" then
                U7.say("\"What’s green as emerald, yet rules no land? Lord British’s crown, for his heart serves Britannia! Ha! Like that one?\"")
                U7.RemoveAnswer("riddle")
            elseif choice == "whispers" then
                U7.say("\"Servants talk of Fellowship folk skulking in the halls, meeting advisors after dark. Even my jests can’t lighten that gloom.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("whispers")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s all smiles and promises, but their eyes dart like thieves in a market. I’d jest about ‘em, but my jokes might cut too deep.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou likest their tune? I’ll keep my japes gentle, then.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to doubt ‘em! Their game’s no laughing matter.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Keep a skip in thy step, \" .. U7.getPlayerName() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_044E