-- func_0474.lua
-- Jorin's dialogue as a fisherman in Britain
local U7 = require("U7LuaFuncs")

function func_0474(eventid)
    local answers = {}
    local flag_00DE = U7.getFlag(0x00DE) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00ED = U7.getFlag(0x00ED) -- Fishing topic
    local npc_id = -93 -- Jorin's NPC ID

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
        if flag_00ED then
            table.insert(answers, "fishing")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00DE then
            U7.say("You see a weathered man mending nets, the smell of fish clinging to his clothes.")
            U7.setFlag(0x00DE, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Jorin says, knotting a rope.")
        end

        while true do
            if #answers == 0 then
                U7.say("Jorin squints at you. \"Need fish or a yarn from the docks?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Jorin, fisherman of Britain’s waters, haulin’ in the day’s catch.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I fish the seas for Britain’s markets. The Fellowship’s trade deals help sell my catch, but their grip on Patterson’s got me uneasy.\"")
                table.insert(answers, "fishing")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00ED, true)
            elseif choice == "fishing" then
                U7.say("\"I pull in cod and herring, but prices are high from taxes. Folk like Weston can’t afford a fish, and that’s stirrin’ trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("fishing")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes drive up my costs. It’s worst for Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—starvin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—sad tale. Figg’s arrest, backed by the Fellowship, was harsh, no mercy for the desperate.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, pushin’ their order. His role in Weston’s arrest shows they care more for control than folk like us.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals get my fish to market, but their ties to Patterson and Figg make me think they’re castin’ a wider net than trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m watchin’ ‘em close.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Smart to doubt ‘em. Their influence is heavier than a full net.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say(\"Fair winds, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0474