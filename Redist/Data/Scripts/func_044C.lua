-- func_044C.lua
-- Geoffrey's dialogue as the captain of the guard in Britain
local U7 = require("U7LuaFuncs")

function func_044C(eventid)
    local answers = {}
    local flag_00C2 = U7.getFlag(0x00C2) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D1 = U7.getFlag(0x00D1) -- Security topic
    local npc_id = -65 -- Geoffrey's NPC ID

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
        if flag_00D1 then
            table.insert(answers, "security")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C2 then
            U7.say("You see a stern man in polished armor, his gaze sharp as he surveys the castle grounds.")
            U7.setFlag(0x00C2, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Geoffrey says with a crisp salute.")
        end

        while true do
            if #answers == 0 then
                U7.say("Geoffrey straightens. \"What business hast thou with me?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Geoffrey, captain of Lord British’s guard.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I command the castle guard, ensuring the safety of Lord British and Britannia’s heart. Crime’s rising, though, and my men are stretched thin.\"")
                table.insert(answers, "security")
                table.insert(answers, "crime")
                U7.setFlag(0x00D1, true)
            elseif choice == "security" then
                U7.say("\"The castle’s fortified, but I’ve doubled patrols. Strange visitors—Fellowship folk, mostly—come and go at odd hours. I trust them not.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("security")
            elseif choice == "crime" then
                U7.say("\"Thefts and brawls are up in Britain. Some prisoners, like that Weston fellow, claim desperation, but I suspect organized trouble. The Fellowship’s name keeps surfacing.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("crime")
            elseif choice == "Weston" then
                U7.say("\"Weston’s in jail for stealing apples. Figg pushed hard for his arrest. I pity the man’s family, but the law’s the law.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a loyal servant, but his zeal borders on cruelty. He’s tight with the Fellowship, which makes me question his motives.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s influence grows, and I mislike their secrecy. They’ve offered to ‘aid’ my guards, but I’ll not have outsiders meddling in castle affairs.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou thinkest them trustworthy? I’ll keep an open mind, but my eyes are sharper.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Good. Stay wary, Avatar. They’re not what they seem.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Stay vigilant, \" .. U7.getPlayerName() .. \". Britannia counts on thee.\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_044C