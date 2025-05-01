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

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00D2 then
            add_answer( "governance")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00C3 then
            add_dialogue("You see a scholarly man with ink-stained fingers, poring over a ledger.")
            set_flag(0x00C3, true)
        else
            add_dialogue("\"Greetings, \" .. U7.getPlayerName() .. \",\" Jergan says, adjusting his spectacles.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Jergan closes his ledger. \"What brings thee to me?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Jergan, advisor to Lord British on matters of governance.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I counsel Lord British on policy, taxes, and law. Britannia’s stability depends on careful stewardship, though recent troubles test us.\"")
                add_answer( "governance")
                add_answer( "troubles")
                set_flag(0x00D2, true)
            elseif choice == "governance" then
                add_dialogue("\"Ruling Britannia requires balancing noble ambitions with the needs of the common folk. The Fellowship’s growing sway complicates matters.\"")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("governance")
            elseif choice == "troubles" then
                add_dialogue("\"Crime rises, and whispers of discontent grow. Some blame the Fellowship for stirring unrest, though they claim to seek harmony.\"")
                add_answer( "Fellowship")
                add_answer( "crime")
                remove_answer("troubles")
            elseif choice == "crime" then
                add_dialogue("\"Geoffrey reports increased thefts, like that poor Weston’s case. I suspect the Fellowship may be exploiting such desperation for their own ends.\"")
                add_answer( "Weston")
                add_answer( "Fellowship")
                remove_answer("crime")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s plight is tragic—a farmer driven to theft by hunger. Figg’s harshness and Fellowship ties make me question justice in his case.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s loyalty to the Fellowship clouds his judgment. He sees threats where there may be only desperation, as with Weston.\"")
                add_answer( "Fellowship")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s rhetoric of unity hides a hunger for control. They court nobles and commoners alike, but their true aims elude me. Be wary, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou seest merit in them? I’ll reconsider, but cautiously.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Thy skepticism aligns with mine. Dig deeper, for Britannia’s sake.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Wisdom guide thee, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_044D