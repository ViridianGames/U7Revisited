-- func_0458.lua
-- Candice's dialogue as a Fellowship treasurer in Britain
local U7 = require("U7LuaFuncs")

function func_0458(eventid)
    local answers = {}
    local flag_00CE = U7.getFlag(0x00CE) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00DD = U7.getFlag(0x00DD) -- Finances topic
    local npc_id = -77 -- Candice's NPC ID

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
        if flag_00DD then
            table.insert(answers, "finances")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00CE then
            U7.say("You see a sharply dressed woman with a Fellowship medallion, reviewing a ledger with keen focus.")
            U7.setFlag(0x00CE, true)
        else
            U7.say("\"Welcome, \" .. U7.getPlayerName() .. \",\" Candice says, her voice steady and professional.")
        end

        while true do
            if #answers == 0 then
                U7.say("Candice closes her ledger. \"How may I assist thee on behalf of the Fellowship?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Candice, treasurer for the Fellowship, managing our resources under Batlin’s guidance.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I oversee the Fellowship’s finances, ensuring our work thrives with Batlin, Elizabeth, Abraham, Ellen, and Klog. Our stability counters disruptions like Brownie’s campaign.\"")
                table.insert(answers, "finances")
                table.insert(answers, "Batlin")
                table.insert(answers, "Brownie")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00DD, true)
            elseif choice == "finances" then
                U7.say("\"Our funds support Britannia’s unity, aiding allies like Patterson and offering aid to those like Weston, had he sought our help instead of theft.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Patterson")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("finances")
            elseif choice == "Batlin" then
                U7.say("\"Batlin’s vision fuels our mission. With Elizabeth, Abraham, Ellen, and Klog, we secure Britannia’s future, despite rabble-rousers like Brownie.\"")
                table.insert(answers, "Brownie")
                U7.RemoveAnswer("Batlin")
            elseif choice == "Brownie" then
                U7.say("\"Brownie’s mayoral bid undermines Britain’s progress. The Fellowship, with Patterson’s support, ensures financial and social order.\"")
                table.insert(answers, "Patterson")
                U7.RemoveAnswer("Brownie")
            elseif choice == "Patterson" then
                U7.say("\"Mayor Patterson’s contributions bolster our resources. His leadership aligns with our goals, fostering stability over Brownie’s discord.\"")
                U7.RemoveAnswer("Patterson")
            elseif choice == "Weston" then
                U7.say("\"Weston’s crime was a tragedy, but Figg’s justice, guided by our principles, was just. Our aid could have spared him such a fate.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s diligence, as seen in Weston’s case, upholds our commitment to Britannia’s prosperity. His loyalty is invaluable.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship unites Britannia, our resources fueling a shared vision. Join us, and contribute to a harmonious future, as many have.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thy willingness is inspiring. Meet Batlin or Elizabeth to join our cause.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Doubt is a step to understanding. Visit our hall, and our work will show thee the truth.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Choose the path of unity, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0458