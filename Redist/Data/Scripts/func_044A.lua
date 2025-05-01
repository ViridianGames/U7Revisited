-- func_044A.lua
-- Lord British's dialogue as the ruler of Britannia
local U7 = require("U7LuaFuncs")

function func_044A(eventid)
    local answers = {}
    local flag_00C1 = U7.getFlag(0x00C1) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D0 = U7.getFlag(0x00D0) -- Kingdom topic
    local npc_id = -64 -- Lord British's NPC ID

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
        if flag_00D0 then
            table.insert(answers, "kingdom")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C1 then
            U7.say("You see a regal figure in a crown, his eyes warm yet burdened with the weight of rule.")
            U7.setFlag(0x00C1, true)
        else
            U7.say("\"Welcome, \" .. U7.getPlayerName() .. \", my friend,\" Lord British says with a nod.")
        end

        while true do
            if #answers == 0 then
                U7.say("Lord British leans forward. \"What troubles thee, Avatar?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I am Lord British, ruler of Britannia, though thou knowest me well, Avatar.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I govern Britannia, striving to uphold the Virtues and ensure prosperity for all. Yet, challenges grow, and I rely on thee to aid our land.\"")
                table.insert(answers, "kingdom")
                table.insert(answers, "Virtues")
                U7.setFlag(0x00D0, true)
            elseif choice == "kingdom" then
                U7.say("\"Britannia thrives, yet shadows stir. The Fellowship’s influence spreads, and I hear troubling whispers of unrest. Thy presence gives me hope.\"")
                table.insert(answers, "Fellowship")
                table.insert(answers, "unrest")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("kingdom")
            elseif choice == "Virtues" then
                U7.say("\"The Eight Virtues guide us—Honesty, Compassion, Valor, Justice, Sacrifice, Honor, Spirituality, and Humility. I fear some turn from them, swayed by easier paths.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("Virtues")
            elseif choice == "unrest" then
                U7.say("\"There are tales of theft, discord, and strange happenings. My advisors suspect the Fellowship may play a role, though they cloak their actions in goodwill.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("unrest")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship speaks of unity and progress, but their secrecy concerns me. They’ve gained favor in Britain, yet I sense not all is as it seems. Watch them closely, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thy faith in their cause is noted, but remain vigilant.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Thy caution is wise. Investigate their doings, for Britannia’s sake.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Go with the Virtues, \" .. U7.getPlayerName() .. \". Britannia needs thee.\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_044A