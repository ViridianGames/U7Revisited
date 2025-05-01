-- func_0462.lua
-- Cynthia's dialogue as a banker in Britain
local U7 = require("U7LuaFuncs")

function func_0462(eventid)
    local answers = {}
    local flag_00D2 = U7.getFlag(0x00D2) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E1 = U7.getFlag(0x00E1) -- Finances topic
    local npc_id = -81 -- Cynthia's NPC ID

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
        if flag_00E1 then
            table.insert(answers, "finances")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D2 then
            U7.say("You see a composed woman with a ledger, managing accounts behind a bank counter.")
            U7.setFlag(0x00D2, true)
        else
            U7.say("\"Welcome back, \" .. U7.getPlayerName() .. \",\" Cynthia says with a polite smile.")
        end

        while true do
            if #answers == 0 then
                U7.say("Cynthia adjusts her ledger. \"What banking needs dost thou have?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Cynthia, banker of Britain, managing the city’s wealth.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I oversee Britain’s finances, handling accounts and loans. The Fellowship’s donations aid stability, but their influence grows strong.\"")
                table.insert(answers, "finances")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E1, true)
            elseif choice == "finances" then
                U7.say("\"The city’s coffers are steady, but poverty festers in Paws. Cases like Weston’s show how desperation strains our system.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Paws")
                U7.RemoveAnswer("finances")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village nearby. Many, like Weston, struggle to survive, and the Fellowship’s promises of aid often fall short.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole to feed his family, but Figg’s swift justice, backed by the Fellowship, left no room for mercy.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s loyalty to the Fellowship drives his actions, like Weston’s arrest. His zeal worries me more than his intent.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship funds civic projects, but their sway over Patterson and others makes me question their true goals.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou seest their good? Perhaps, but their influence bears watching.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Thy caution aligns with mine. Their motives may not be as pure as claimed.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Farewell, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0462