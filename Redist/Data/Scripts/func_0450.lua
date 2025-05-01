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

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00D5 then
            table.insert(answers, "justice")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C6 then
            U7.say("You see a poised woman in fine robes, reviewing a scroll of laws with a steady gaze.")
            U7.setFlag(0x00C6, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Miranda says with a measured nod.")
        end

        while true do
            if #answers == 0 then
                U7.say("Miranda sets aside her scroll. \"What matter dost thou bring before me?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Miranda, councilor to Lord British, keeper of Britannia’s laws.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I draft and uphold the laws of Britannia, ensuring justice prevails. Yet, the Fellowship’s influence tests the balance of our courts.\"")
                table.insert(answers, "justice")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00D5, true)
            elseif choice == "justice" then
                U7.say("\"Justice must be fair, yet firm. Cases like Weston’s trouble me—poverty drives crime, but the Fellowship’s sway over judgments concerns me more.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("justice")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his family, yet Figg’s harsh sentence reeks of Fellowship bias. I’m reviewing his case, but pressure mounts.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s devotion to the Fellowship blinds him to mercy. His accusations against Weston were swift, perhaps too swift.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s calls for unity mask a desire for power. They lobby for lenient laws for their members, undermining justice. I urge thee to probe their motives, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou seest good in them? I’ll weigh their words, but my trust is thin.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Thy caution is prudent. Uncover their true aims, for Britannia’s laws depend on it.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Let justice guide thee, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0450