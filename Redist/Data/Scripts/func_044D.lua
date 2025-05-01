-- func_044D.lua
-- Jergan's dialogue as a castle advisor in Britain
local U7 = require("U7LuaFuncs")

function func_044D(eventid)
    local answers = {}
    local flag_00C3 = U7.getFlag(0x00C3) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D2 = U7.getFlag(0x00D2) -- Governance topic
    local npc_id = -66 -- Jergan's NPC ID

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
        if flag_00D2 then
            table.insert(answers, "governance")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C3 then
            U7.say("You see a scholarly man with ink-stained fingers, poring over a ledger.")
            U7.setFlag(0x00C3, true)
        else
            U7.say("\"Greetings, \" .. U7.getPlayerName() .. \",\" Jergan says, adjusting his spectacles.")
        end

        while true do
            if #answers == 0 then
                U7.say("Jergan closes his ledger. \"What brings thee to me?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Jergan, advisor to Lord British on matters of governance.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I counsel Lord British on policy, taxes, and law. Britannia’s stability depends on careful stewardship, though recent troubles test us.\"")
                table.insert(answers, "governance")
                table.insert(answers, "troubles")
                U7.setFlag(0x00D2, true)
            elseif choice == "governance" then
                U7.say("\"Ruling Britannia requires balancing noble ambitions with the needs of the common folk. The Fellowship’s growing sway complicates matters.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("governance")
            elseif choice == "troubles" then
                U7.say("\"Crime rises, and whispers of discontent grow. Some blame the Fellowship for stirring unrest, though they claim to seek harmony.\"")
                table.insert(answers, "Fellowship")
                table.insert(answers, "crime")
                U7.RemoveAnswer("troubles")
            elseif choice == "crime" then
                U7.say("\"Geoffrey reports increased thefts, like that poor Weston’s case. I suspect the Fellowship may be exploiting such desperation for their own ends.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("crime")
            elseif choice == "Weston" then
                U7.say("\"Weston’s plight is tragic—a farmer driven to theft by hunger. Figg’s harshness and Fellowship ties make me question justice in his case.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s loyalty to the Fellowship clouds his judgment. He sees threats where there may be only desperation, as with Weston.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s rhetoric of unity hides a hunger for control. They court nobles and commoners alike, but their true aims elude me. Be wary, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou seest merit in them? I’ll reconsider, but cautiously.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Thy skepticism aligns with mine. Dig deeper, for Britannia’s sake.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Wisdom guide thee, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_044D