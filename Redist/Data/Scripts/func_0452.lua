-- func_0452.lua
-- Patterson's dialogue as the mayor of Britain
local U7 = require("U7LuaFuncs")

function func_0452(eventid)
    local answers = {}
    local flag_00C8 = U7.getFlag(0x00C8) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D7 = U7.getFlag(0x00D7) -- Governance topic
    local npc_id = -71 -- Patterson's NPC ID

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
        if flag_00D7 then
            table.insert(answers, "governance")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C8 then
            U7.say("You see a polished man in fine attire, exuding confidence but with a guarded smile.")
            U7.setFlag(0x00C8, true)
        else
            U7.say("\"Welcome, \" .. U7.getPlayerName() .. \",\" Patterson says with a practiced nod.")
        end

        while true do
            if #answers == 0 then
                U7.say("Patterson adjusts his cloak. \"What business hast thou with Britain’s mayor?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Patterson, mayor of Britain, serving its people with pride.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I govern Britain, ensuring its prosperity and order. The Fellowship aids my efforts, though some, like that farmer Brownie, challenge my rule.\"")
                table.insert(answers, "governance")
                table.insert(answers, "Brownie")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00D7, true)
            elseif choice == "governance" then
                U7.say("\"Running Britain demands strength. Taxes fund our growth, and the Fellowship’s support keeps order, despite rabble-rousers like Brownie.\"")
                table.insert(answers, "Brownie")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("governance")
            elseif choice == "Brownie" then
                U7.say("\"Brownie’s a farmer stirring trouble with his mayoral campaign. He claims I favor the Fellowship, but his ideas would bankrupt Britain.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("Brownie")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship brings unity and progress. Their guidance strengthens Britain, though some distrust them. I find their vision aligns with mine.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou seest their value? Good. They’re key to Britain’s future.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Distrust them? Speak to their leaders—thou wilt see their worth.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Fare well, \" .. U7.getPlayerName() .. \". Support Britain’s progress.\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0452