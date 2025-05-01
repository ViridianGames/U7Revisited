-- func_0460.lua
-- Finn's dialogue as a beggar in Britain
local U7 = require("U7LuaFuncs")

function func_0460(eventid)
    local answers = {}
    local flag_00D0 = U7.getFlag(0x00D0) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00DF = U7.getFlag(0x00DF) -- Poverty topic
    local npc_id = -79 -- Finn's NPC ID

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
        if flag_00DF then
            table.insert(answers, "poverty")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D0 then
            U7.say("You see a ragged man with weary eyes, clutching a worn cup for coins.")
            U7.setFlag(0x00D0, true)
        else
            U7.say("\"Thou’rt back, \" .. U7.getPlayerName() .. \",\" Finn mutters, shivering.")
        end

        while true do
            if #answers == 0 then
                U7.say("Finn coughs. \"Spare a word or a coin for a poor soul?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Finn, just a beggar, forgotten by most in Britain.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"Ain’t got no job. I beg to eat, like others in Paws. The Fellowship promises help, but I seen none.\"")
                table.insert(answers, "poverty")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00DF, true)
            elseif choice == "poverty" then
                U7.say("\"Paws is starvin’, like me. Folk like Weston tried to feed their kin, and look where it got ‘em—jailed by Figg.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("poverty")
            elseif choice == "Weston" then
                U7.say("\"Weston’s a mate from Paws, nabbed for stealin’ apples. He was desperate, like me. Figg and the Fellowship didn’t care.\"")
                table.insert(answers, "Figg")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a cruel one, workin’ with the Fellowship. He turned Weston in without a thought, all to please ‘em.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship talks big—unity, help for all—but I ain’t seen a coin from ‘em. They’re all smiles for Patterson, not us beggars.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou think they’re kind? Maybe, but they pass me by every day.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Aye, don’t trust ‘em. They’re up to somethin’, mark my words.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Spare a coin someday, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0460