-- func_0459.lua
-- Alagner's dialogue as a scholar in Britain
local U7 = require("U7LuaFuncs")

function func_0459(eventid)
    local answers = {}
    local flag_00CF = U7.getFlag(0x00CF) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00DE = U7.getFlag(0x00DE) -- Research topic
    local npc_id = -78 -- Alagner's NPC ID

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
        if flag_00DE then
            add_answer( "research")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00CF then
            add_dialogue("You see a studious man surrounded by books, eyeing you with cautious curiosity.")
            set_flag(0x00CF, true)
        else
            add_dialogue("\"Back again, \" .. U7.getPlayerName() .. \"?\" Alagner says, adjusting his glasses.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Alagner sets down a book. \"What knowledge dost thou seek?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Alagner, scholar of Britannia’s truths, seeking answers beyond the obvious.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I study Britannia’s history and society, uncovering patterns. The Fellowship’s rise alarms me, as does their sway over folk like Patterson.\"")
                add_answer( "research")
                add_answer( "Patterson")
                add_answer( "Fellowship")
                set_flag(0x00DE, true)
            elseif choice == "research" then
                add_dialogue("\"My research reveals the Fellowship’s influence growing unchecked. Their ties to Figg and Patterson suggest a deeper agenda.\"")
                add_answer( "Figg")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("research")
            elseif choice == "Patterson" then
                add_dialogue("\"Patterson’s alliance with the Fellowship blinds him to their motives. His rivalry with Brownie only strengthens their grip.\"")
                add_answer( "Brownie")
                remove_answer("Patterson")
            elseif choice == "Brownie" then
                add_dialogue("\"Brownie’s campaign, though flawed, resists the Fellowship’s control. His voice is one of few challenging their narrative.\"")
                remove_answer("Brownie")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s zeal in Weston’s case reeks of Fellowship loyalty. His actions serve their order, not justice.\"")
                add_answer( "Weston")
                remove_answer("Figg")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s punishment was harsh, driven by Figg’s Fellowship ties. My research suggests they exploit such cases to justify control.\"")
                remove_answer("Weston")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s unity is a facade for power. Their leaders—Batlin, Elizabeth—hide truths I aim to uncover. Seek their secrets, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest them? I urge caution—my findings point to deception.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Thy skepticism is wise. Dig deeper, for Britannia’s sake.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Seek truth, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0459