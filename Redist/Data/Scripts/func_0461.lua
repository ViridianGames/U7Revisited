-- func_0461.lua
-- Garritt's dialogue as a merchant in Britain
local U7 = require("U7LuaFuncs")

function func_0461(eventid)
    local answers = {}
    local flag_00D1 = U7.getFlag(0x00D1) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E0 = U7.getFlag(0x00E0) -- Trade topic
    local npc_id = -80 -- Garritt's NPC ID

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
        if flag_00E0 then
            table.insert(answers, "trade")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D1 then
            U7.say("You see a well-dressed man with a ledger, overseeing crates in Britain’s market.")
            U7.setFlag(0x00D1, true)
        else
            U7.say("\"Back again, \" .. U7.getPlayerName() .. \"?\" Garritt says, tallying his wares.")
        end

        while true do
            if #answers == 0 then
                U7.say("Garritt glances up. \"What’s thy business in the market?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Garritt, merchant of Britain’s finest goods.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I trade goods in Britain’s market, from cloth to grain. The Fellowship’s push for unity aids business, but their fees sting.\"")
                table.insert(answers, "trade")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E0, true)
            elseif choice == "trade" then
                U7.say("\"Trade’s brisk, but taxes and Fellowship dues cut deep. Folk like Weston suffer most—poverty drives ‘em to desperate acts.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("trade")
            elseif choice == "Weston" then
                U7.say("\"Weston, that poor sod, stole apples to feed his kin. Figg’s harsh justice, backed by the Fellowship, crushed him.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, all about order. His role in Weston’s arrest shows their influence over Britain’s laws.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship boosts trade with their talk of unity, but their dues and ties to Patterson make me wonder what they’re really after.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou thinkest them fair? Mayhap, but their fees hit my purse hard.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Aye, I don’t fully trust ‘em either. Something’s off with their plans.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Safe travels, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0461