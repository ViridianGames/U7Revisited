-- func_0475.lua
-- Tilda's dialogue as a seamstress in Britain
local U7 = require("U7LuaFuncs")

function func_0475(eventid)
    local answers = {}
    local flag_00DF = U7.getFlag(0x00DF) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00EE = U7.getFlag(0x00EE) -- Sewing topic
    local npc_id = -94 -- Tilda's NPC ID

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
        if flag_00EE then
            table.insert(answers, "sewing")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00DF then
            U7.say("You see a deft woman stitching fabric, her shop lined with colorful threads.")
            U7.setFlag(0x00DF, true)
        else
            U7.say("\"Welcome, \" .. U7.getPlayerName() .. \",\" Tilda says, snipping a thread.")
        end

        while true do
            if #answers == 0 then
                U7.say("Tilda sets down her needle. \"Need a mend or some chatter?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Tilda, seamstress of Britain, stitchin’ fine clothes for all.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I sew dresses, tunics, and cloaks. The Fellowship’s trade deals bring thread, but their hold on Patterson’s got me a bit wary.\"")
                table.insert(answers, "sewing")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00EE, true)
            elseif choice == "sewing" then
                U7.say("\"I craft garments from linen to silk, but prices are high. Folk like Weston can’t afford a new shirt, and that’s causin’ trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("sewing")
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
                U7.say("\"Weston stole apples to feed his kin—such a pity. Figg’s arrest, backed by the Fellowship, was harsh, no kindness shown.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my shop threaded, but their ties to Patterson and Figg make me think they’re weavin’ a bigger plan.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m keepin’ my eyes sharp.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to doubt ‘em. Their influence is heavier than a bolt of silk.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Keep thy seams tight, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0475