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

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00D4 then
            add_answer( "lore")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00C5 then
            add_dialogue("You see an aged scholar surrounded by dusty tomes, scribbling notes with a quill.")
            set_flag(0x00C5, true)
        else
            add_dialogue("\"Well met, \" .. U7.getPlayerName() .. \",\" Inwistain says, peering over his spectacles.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Inwistain sets down his quill. \"What knowledge dost thou seek?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Inwistain, scholar and keeper of Britannia’s lore in Castle British.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I study Britannia’s history and counsel Lord British on matters of lore. The past holds lessons, but new shadows like the Fellowship trouble me.\"")
                add_answer( "lore")
                add_answer( "Fellowship")
                set_flag(0x00D4, true)
            elseif choice == "lore" then
                add_dialogue("\"Britannia’s tales speak of heroes like thee, Avatar, and perils overcome. Yet, the Fellowship’s rise echoes darker chapters of ambition.\"")
                add_answer( "Fellowship")
                add_answer( "history")
                set_flag(0x0094, true)
                remove_answer("lore")
            elseif choice == "history" then
                add_dialogue("\"From the Age of Darkness to the Quest of the Avatar, Britannia’s story is one of struggle and virtue. I fear the Fellowship may rewrite it for their own ends.\"")
                add_answer( "Fellowship")
                remove_answer("history")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship claims to unify, but their texts hint at control, not unlike old cults in our annals. Their secrecy recalls dangers past—investigate them, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou findest merit in their words? I’ll review their texts again, but with caution.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Thy wariness matches my own. Seek their true intent, for Britannia’s history depends on it.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"May wisdom guide thee, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_044F