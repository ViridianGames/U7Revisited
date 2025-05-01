-- func_0483.lua
-- Myra's dialogue as a florist in Britain
local U7 = require("U7LuaFuncs")

function func_0483(eventid)
    local answers = {}
    local flag_00E7 = U7.getFlag(0x00E7) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00F6 = U7.getFlag(0x00F6) -- Flowers topic
    local npc_id = -102 -- Myra's NPC ID

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
        if flag_00F6 then
            table.insert(answers, "flowers")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00E7 then
            U7.say("You see a cheerful woman arranging flowers, her shop bursting with colorful blooms.")
            U7.setFlag(0x00E7, true)
        else
            U7.say("\"Welcome, \" .. U7.getPlayerName() .. \",\" Myra says, trimming a stem.")
        end

        while true do
            if #answers == 0 then
                U7.say("Myra smiles brightly. \"Need a bouquet or some gossip?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Myra, florist of Britain, bringin’ beauty to all with my flowers.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I grow and sell flowers—roses, lilies, and more. The Fellowship’s trade deals bring seeds, but their hold on Patterson’s got me a bit wary.\"")
                table.insert(answers, "flowers")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00F6, true)
            elseif choice == "flowers" then
                U7.say("\"My blooms brighten any day, but prices are high from taxes. Folk like Weston can’t afford a single rose, and that’s causin’ trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("flowers")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes drive up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—such a pity. Figg’s arrest, backed by the Fellowship, was harsh, no kindness shown.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my shop bloomin’, but their ties to Patterson and Figg make me think they’re plantin’ more than just trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m keepin’ a close eye.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to doubt ‘em. Their influence is heavier than a bushel of roses.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Brighten thy day, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0483