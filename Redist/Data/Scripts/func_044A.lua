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

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00D0 then
            add_answer( "kingdom")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00C1 then
            add_dialogue("You see a regal figure in a crown, his eyes warm yet burdened with the weight of rule.")
            set_flag(0x00C1, true)
        else
            add_dialogue("\"Welcome, \" .. U7.getPlayerName() .. \", my friend,\" Lord British says with a nod.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Lord British leans forward. \"What troubles thee, Avatar?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"I am Lord British, ruler of Britannia, though thou knowest me well, Avatar.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I govern Britannia, striving to uphold the Virtues and ensure prosperity for all. Yet, challenges grow, and I rely on thee to aid our land.\"")
                add_answer( "kingdom")
                add_answer( "Virtues")
                set_flag(0x00D0, true)
            elseif choice == "kingdom" then
                add_dialogue("\"Britannia thrives, yet shadows stir. The Fellowship’s influence spreads, and I hear troubling whispers of unrest. Thy presence gives me hope.\"")
                add_answer( "Fellowship")
                add_answer( "unrest")
                set_flag(0x0094, true)
                remove_answer("kingdom")
            elseif choice == "Virtues" then
                add_dialogue("\"The Eight Virtues guide us—Honesty, Compassion, Valor, Justice, Sacrifice, Honor, Spirituality, and Humility. I fear some turn from them, swayed by easier paths.\"")
                add_answer( "Fellowship")
                remove_answer("Virtues")
            elseif choice == "unrest" then
                add_dialogue("\"There are tales of theft, discord, and strange happenings. My advisors suspect the Fellowship may play a role, though they cloak their actions in goodwill.\"")
                add_answer( "Fellowship")
                remove_answer("unrest")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship speaks of unity and progress, but their secrecy concerns me. They’ve gained favor in Britain, yet I sense not all is as it seems. Watch them closely, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thy faith in their cause is noted, but remain vigilant.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Thy caution is wise. Investigate their doings, for Britannia’s sake.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Go with the Virtues, \" .. U7.getPlayerName() .. \". Britannia needs thee.\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_044A