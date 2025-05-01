-- func_044F.lua
-- Inwistain's dialogue as a scholar in Castle British
local U7 = require("U7LuaFuncs")

function func_044F(eventid)
    local answers = {}
    local flag_00C5 = U7.getFlag(0x00C5) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D4 = U7.getFlag(0x00D4) -- Lore topic
    local npc_id = -68 -- Inwistain's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Item interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00D4 then
            table.insert(answers, "lore")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C5 then
            U7.say("You see an aged scholar surrounded by dusty tomes, scribbling notes with a quill.")
            U7.setFlag(0x00C5, true)
        else
            U7.say("\"Well met, \" .. U7.getPlayerName() .. \",\" Inwistain says, peering over his spectacles.")
        end

        while true do
            if #answers == 0 then
                U7.say("Inwistain sets down his quill. \"What knowledge dost thou seek?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Inwistain, scholar and keeper of Britannia’s lore in Castle British.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I study Britannia’s history and counsel Lord British on matters of lore. The past holds lessons, but new shadows like the Fellowship trouble me.\"")
                table.insert(answers, "lore")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00D4, true)
            elseif choice == "lore" then
                U7.say("\"Britannia’s tales speak of heroes like thee, Avatar, and perils overcome. Yet, the Fellowship’s rise echoes darker chapters of ambition.\"")
                table.insert(answers, "Fellowship")
                table.insert(answers, "history")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("lore")
            elseif choice == "history" then
                U7.say("\"From the Age of Darkness to the Quest of the Avatar, Britannia’s story is one of struggle and virtue. I fear the Fellowship may rewrite it for their own ends.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("history")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship claims to unify, but their texts hint at control, not unlike old cults in our annals. Their secrecy recalls dangers past—investigate them, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou findest merit in their words? I’ll review their texts again, but with caution.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Thy wariness matches my own. Seek their true intent, for Britannia’s history depends on it.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"May wisdom guide thee, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_044F