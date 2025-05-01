-- func_043E.lua
-- Brownie's dialogue as a farmer and mayoral candidate in Britain
local U7 = require("U7LuaFuncs")

function func_043E(eventid)
    local answers = {}
    local flag_00B5 = U7.getFlag(0x00B5) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00C7 = U7.getFlag(0x00C7) -- Campaign topic
    local npc_id = -52 -- Brownie's NPC ID

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
        if flag_00C7 then
            table.insert(answers, "campaign")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00B5 then
            U7.say("You see a sturdy farmer with calloused hands and a hopeful smile.")
            U7.setFlag(0x00B5, true)
        else
            U7.say("\"Well met, \" .. U7.getPlayerName() .. \"!\" Brownie says cheerfully.")
        end

        while true do
            if #answers == 0 then
                U7.say("Brownie nods. \"Anything else I can help thee with?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I’m Brownie, farmer and candidate for mayor of Britain.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I farm the fields north of Britain—potatoes, carrots, and the like. Also running for mayor to make things fairer for folk like me.\"")
                table.insert(answers, "farming")
                table.insert(answers, "mayor")
            elseif choice == "farming" then
                U7.say("\"It’s honest work. Sunup to sundown, tending crops. I sell my produce at market, but prices are tight with taxes so high.\"")
                table.insert(answers, "taxes")
                table.insert(answers, "market")
                U7.RemoveAnswer("farming")
            elseif choice == "market" then
                U7.say("\"Britain’s market is bustling, but the fees to sell there eat into my earnings. If I’m mayor, I’ll lower those fees for farmers.\"")
                U7.RemoveAnswer("market")
            elseif choice == "taxes" then
                U7.say("\"Lord British means well, but his taxes hit small farmers hard. The Fellowship’s been pushing for exemptions, but only for their own.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("taxes")
            elseif choice == "mayor" then
                U7.say("\"I’m running for mayor to give the common folk a voice. Britain’s run by nobles and guilds, but farmers and workers deserve better.\"")
                table.insert(answers, "campaign")
                U7.setFlag(0x00C7, true)
                U7.RemoveAnswer("mayor")
            elseif choice == "campaign" then
                U7.say("\"My campaign’s about fairness. Lower taxes, fewer fees, and less influence from groups like the Fellowship. I’ve got support from farmers, but the nobles aren’t keen.\"")
                table.insert(answers, "support")
                U7.RemoveAnswer("campaign")
            elseif choice == "support" then
                U7.say("\"Folks in Paws and the fields back me, but I need more votes in Britain. If thou couldst spread the word, I’d be grateful.\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    U7.say("\"Thou’lt help? Bless thee! Here’s a carrot from my fields.\"")
                    local item_result = U7.giveItem(16, 1, 383)
                    if not item_result then
                        U7.say("\"Oh, thou art too laden to carry it. Clear some space!\"")
                    end
                else
                    U7.say("\"No matter, I’ll keep at it.\"")
                end
                U7.RemoveAnswer("support")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship claims to help all, but they favor their own. I’ve seen them pressure farmers to join or face trouble at market. I don’t trust ‘em.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Maybe I’m too harsh. I’ll think on their ideas.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Nay, I’ve seen enough to know they’re not for me.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Vote for Brownie, \" .. U7.getPlayerName() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_043E