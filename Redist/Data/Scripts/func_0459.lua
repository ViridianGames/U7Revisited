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

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00DE then
            table.insert(answers, "research")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00CF then
            U7.say("You see a studious man surrounded by books, eyeing you with cautious curiosity.")
            U7.setFlag(0x00CF, true)
        else
            U7.say("\"Back again, \" .. U7.getPlayerName() .. \"?\" Alagner says, adjusting his glasses.")
        end

        while true do
            if #answers == 0 then
                U7.say("Alagner sets down a book. \"What knowledge dost thou seek?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Alagner, scholar of Britannia’s truths, seeking answers beyond the obvious.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I study Britannia’s history and society, uncovering patterns. The Fellowship’s rise alarms me, as does their sway over folk like Patterson.\"")
                table.insert(answers, "research")
                table.insert(answers, "Patterson")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00DE, true)
            elseif choice == "research" then
                U7.say("\"My research reveals the Fellowship’s influence growing unchecked. Their ties to Figg and Patterson suggest a deeper agenda.\"")
                table.insert(answers, "Figg")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("research")
            elseif choice == "Patterson" then
                U7.say("\"Patterson’s alliance with the Fellowship blinds him to their motives. His rivalry with Brownie only strengthens their grip.\"")
                table.insert(answers, "Brownie")
                U7.RemoveAnswer("Patterson")
            elseif choice == "Brownie" then
                U7.say("\"Brownie’s campaign, though flawed, resists the Fellowship’s control. His voice is one of few challenging their narrative.\"")
                U7.RemoveAnswer("Brownie")
            elseif choice == "Figg" then
                U7.say("\"Figg’s zeal in Weston’s case reeks of Fellowship loyalty. His actions serve their order, not justice.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Figg")
            elseif choice == "Weston" then
                U7.say("\"Weston’s punishment was harsh, driven by Figg’s Fellowship ties. My research suggests they exploit such cases to justify control.\"")
                U7.RemoveAnswer("Weston")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s unity is a facade for power. Their leaders—Batlin, Elizabeth—hide truths I aim to uncover. Seek their secrets, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest them? I urge caution—my findings point to deception.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Thy skepticism is wise. Dig deeper, for Britannia’s sake.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Seek truth, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0459