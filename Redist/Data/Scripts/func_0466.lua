-- func_0466.lua
-- Gaylen's dialogue as a baker in Britain
local U7 = require("U7LuaFuncs")

function func_0466(eventid)
    local answers = {}
    local flag_00D6 = U7.getFlag(0x00D6) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E5 = U7.getFlag(0x00E5) -- Bakery topic
    local npc_id = -85 -- Gaylen's NPC ID

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
        if flag_00E5 then
            table.insert(answers, "bakery")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D6 then
            U7.say("You see a stout man kneading dough, the warm scent of bread filling his bakery.")
            U7.setFlag(0x00D6, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Gaylen says, dusting flour off his hands.")
        end

        while true do
            if #answers == 0 then
                U7.say("Gaylen wipes his brow. \"Fancy a loaf or a chat?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Gaylen, baker of Britain’s best bread and pastries.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I bake bread, rolls, and sweets for Britain. The Fellowship’s trade deals bring grain, but their sway over Patterson makes me uneasy.\"")
                table.insert(answers, "bakery")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E5, true)
            elseif choice == "bakery" then
                U7.say("\"My loaves are fresh daily, but prices are high from taxes. Folk like Weston can’t afford bread, and that’s a recipe for trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("bakery")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes jack up my costs. It’s hardest on Paws folk, pushin’ ‘em to desperate acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—starvin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—gut-wrenchin’. Figg’s arrest, with Fellowship backin’, was harsh, no mercy shown.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s tied to the Fellowship, enforcin’ their order. His role in Weston’s arrest shows they value control over compassion.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s grain deals keep my ovens hot, but their hold on Patterson and folk like Figg makes me wonder what they’re really bakin’.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They help trade, but I’m keepin’ my eyes peeled.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Good call, questionin’ ‘em. Their influence feels heavier than their promises.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Enjoy thy day, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0466