require "U7LuaFuncs"
-- func_0476.lua
-- Bram's dialogue as a butcher in Britain
local U7 = require("U7LuaFuncs")

function func_0476(eventid)
    local answers = {}
    local flag_00E0 = U7.getFlag(0x00E0) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00EF = U7.getFlag(0x00EF) -- Butcher topic
    local npc_id = -95 -- Bram's NPC ID

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
        if flag_00EF then
            table.insert(answers, "butcher")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00E0 then
            U7.say("You see a hearty man chopping meat, his butcher shop filled with the scent of fresh cuts.")
            U7.setFlag(0x00E0, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Bram says, wiping his cleaver.")
        end

        while true do
            if #answers == 0 then
                U7.say("Bram grins. \"Need a cut of meat or some talk?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Bram, butcher of Britain, providin’ the finest meats.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I run this butcher shop, sellin’ beef, pork, and more. The Fellowship’s trade deals keep my stock fresh, but their hold on Patterson’s troublin’.\"")
                table.insert(answers, "butcher")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00EF, true)
            elseif choice == "butcher" then
                U7.say("\"I’ve got prime cuts daily, but prices are steep from taxes. Folk like Weston can’t afford a scrap, and that’s stirrin’ up trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("butcher")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes drive up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—starvin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—damn shame. Figg’s arrest, backed by the Fellowship, was harsh, no care for his plight.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their rules. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my shop stocked, but their ties to Patterson and Figg make me think they’re carvin’ out more than just trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m keepin’ a sharp eye.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to doubt ‘em. Their influence is heavier than my cleaver.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Stay hearty, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0476