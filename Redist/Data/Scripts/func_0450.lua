-- func_0450.lua
-- Miranda's dialogue as a councilor in Castle British
local U7 = require("U7LuaFuncs")

function func_0450(eventid)
    local answers = {}
    local flag_00C6 = U7.getFlag(0x00C6) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D5 = U7.getFlag(0x00D5) -- Justice topic
    local npc_id = -69 -- Miranda's NPC ID

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
        if flag_00D5 then
            add_answer( "justice")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00C6 then
            add_dialogue("You see a poised woman in fine robes, reviewing a scroll of laws with a steady gaze.")
            set_flag(0x00C6, true)
        else
            add_dialogue("\"Hail, \" .. U7.getPlayerName() .. \",\" Miranda says with a measured nod.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Miranda sets aside her scroll. \"What matter dost thou bring before me?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Miranda, councilor to Lord British, keeper of Britannia’s laws.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I draft and uphold the laws of Britannia, ensuring justice prevails. Yet, the Fellowship’s influence tests the balance of our courts.\"")
                add_answer( "justice")
                add_answer( "Fellowship")
                set_flag(0x00D5, true)
            elseif choice == "justice" then
                add_dialogue("\"Justice must be fair, yet firm. Cases like Weston’s trouble me—poverty drives crime, but the Fellowship’s sway over judgments concerns me more.\"")
                add_answer( "Weston")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("justice")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his family, yet Figg’s harsh sentence reeks of Fellowship bias. I’m reviewing his case, but pressure mounts.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s devotion to the Fellowship blinds him to mercy. His accusations against Weston were swift, perhaps too swift.\"")
                add_answer( "Fellowship")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s calls for unity mask a desire for power. They lobby for lenient laws for their members, undermining justice. I urge thee to probe their motives, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou seest good in them? I’ll weigh their words, but my trust is thin.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Thy caution is prudent. Uncover their true aims, for Britannia’s laws depend on it.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Let justice guide thee, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0450