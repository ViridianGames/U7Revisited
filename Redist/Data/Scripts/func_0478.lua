-- func_0478.lua
-- Liora's dialogue as a weaver in Britain
local U7 = require("U7LuaFuncs")

function func_0478(eventid)
    local answers = {}
    local flag_00E2 = U7.getFlag(0x00E2) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00F1 = U7.getFlag(0x00F1) -- Weaving topic
    local npc_id = -97 -- Liora's NPC ID

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
        if flag_00F1 then
            table.insert(answers, "weaving")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00E2 then
            U7.say("You see a skilled woman working a loom, her shop vibrant with woven tapestries.")
            U7.setFlag(0x00E2, true)
        else
            U7.say("\"Greetings, \" .. U7.getPlayerName() .. \",\" Liora says, adjusting her loom.")
        end

        while true do
            if #answers == 0 then
                U7.say("Liora pauses her weaving. \"Need cloth or a word?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Liora, weaver of Britain, craftin’ fine fabrics for all.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I weave cloth—blankets, rugs, and more. The Fellowship’s trade deals bring wool, but their hold on Patterson’s got me uneasy.\"")
                table.insert(answers, "weaving")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00F1, true)
            elseif choice == "weaving" then
                U7.say("\"I spin wool into fine cloth, but prices are high from taxes. Folk like Weston can’t afford a blanket, and that’s causin’ strife.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("weaving")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes drive up my costs. It’s toughest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—heartbreakin’. Figg’s arrest, backed by the Fellowship, was cold, no mercy given.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my loom busy, but their ties to Patterson and Figg make me think they’re weavin’ a bigger scheme than trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m keepin’ my eye sharp.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to doubt ‘em. Their influence is heavier than my finest cloth.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Keep warm, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0478