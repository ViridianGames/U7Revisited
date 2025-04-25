-- func_0463.lua
-- Sean's dialogue as a jeweler in Britain
local U7 = require("U7LuaFuncs")

function func_0463(eventid)
    local answers = {}
    local flag_00D3 = U7.getFlag(0x00D3) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E2 = U7.getFlag(0x00E2) -- Jewelry topic
    local npc_id = -82 -- Sean's NPC ID

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
        if flag_00E2 then
            table.insert(answers, "jewelry")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D3 then
            U7.say("You see a meticulous man polishing a gem, his shop gleaming with fine jewelry.")
            U7.setFlag(0x00D3, true)
        else
            U7.say("\"Good to see thee, \" .. U7.getPlayerName() .. \",\" Sean says, setting down a ring.")
        end

        while true do
            if #answers == 0 then
                U7.say("Sean smiles. \"Care to browse my wares or chat?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Sean, jeweler of Britain, crafting beauty for the discerning.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I craft and sell jewelry—rings, necklaces, the lot. The Fellowship’s trade deals help, but their grip on folk like Patterson concerns me.\"")
                table.insert(answers, "jewelry")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E2, true)
            elseif choice == "jewelry" then
                U7.say("\"My gems come from Minoc, but taxes make ‘em pricey. Poor folk like Weston can’t afford such luxuries, and that breeds trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Minoc")
                U7.RemoveAnswer("jewelry")
            elseif choice == "Minoc" then
                U7.say("\"Minoc’s mines supply my gems, but the Fellowship’s trade rules raise costs. It’s harder for honest folk to get by.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("Minoc")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his family—sad case. Figg’s quick arrest, pushed by the Fellowship, showed no mercy.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship loyalist, enforcin’ their order. His role in Weston’s case makes me question their so-called unity.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals boost commerce, but their hold over Patterson and push for control makes me wary of their true aims.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest their ways? They aid trade, but I watch ‘em closely.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Good to stay cautious. Their influence runs deeper than they let on.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Come back anytime, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0463