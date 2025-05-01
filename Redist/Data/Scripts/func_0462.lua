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

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00E1 then
            add_answer( "finances")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00D2 then
            add_dialogue("You see a composed woman with a ledger, managing accounts behind a bank counter.")
            set_flag(0x00D2, true)
        else
            add_dialogue("\"Welcome back, \" .. U7.getPlayerName() .. \",\" Cynthia says with a polite smile.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Cynthia adjusts her ledger. \"What banking needs dost thou have?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Cynthia, banker of Britain, managing the city’s wealth.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I oversee Britain’s finances, handling accounts and loans. The Fellowship’s donations aid stability, but their influence grows strong.\"")
                add_answer( "finances")
                add_answer( "Fellowship")
                set_flag(0x00E1, true)
            elseif choice == "finances" then
                add_dialogue("\"The city’s coffers are steady, but poverty festers in Paws. Cases like Weston’s show how desperation strains our system.\"")
                add_answer( "Weston")
                add_answer( "Paws")
                remove_answer("finances")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village nearby. Many, like Weston, struggle to survive, and the Fellowship’s promises of aid often fall short.\"")
                add_answer( "Weston")
                add_answer( "Fellowship")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole to feed his family, but Figg’s swift justice, backed by the Fellowship, left no room for mercy.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s loyalty to the Fellowship drives his actions, like Weston’s arrest. His zeal worries me more than his intent.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship funds civic projects, but their sway over Patterson and others makes me question their true goals.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou seest their good? Perhaps, but their influence bears watching.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Thy caution aligns with mine. Their motives may not be as pure as claimed.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Farewell, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0462