-- func_0468.lua
-- Carlyn's dialogue as a healer in Britain
local U7 = require("U7LuaFuncs")

function func_0468(eventid)
    local answers = {}
    local flag_00D8 = U7.getFlag(0x00D8) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E7 = U7.getFlag(0x00E7) -- Healing topic
    local npc_id = -87 -- Carlyn's NPC ID

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
        if flag_00E7 then
            table.insert(answers, "healing")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D8 then
            U7.say("You see a gentle woman tending to a patient, her hands steady with care.")
            U7.setFlag(0x00D8, true)
        else
            U7.say("\"Welcome, \" .. U7.getPlayerName() .. \",\" Carlyn says, offering a kind smile.")
        end

        while true do
            if #answers == 0 then
                U7.say("Carlyn cleans a bandage. \"Need aid or just a word?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Carlyn, healer of Britain, tendin’ to the sick and weary.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I heal wounds and ailments for Britain’s folk. The Fellowship offers aid, but their influence on Patterson troubles me.\"")
                table.insert(answers, "healing")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E7, true)
            elseif choice == "healing" then
                U7.say("\"I treat cuts, fevers, and more, but supplies are costly. Poor folk like Weston can’t afford care, and that breeds despair.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "supplies")
                U7.RemoveAnswer("healing")
            elseif choice == "supplies" then
                U7.say("\"Herbs and bandages cost a fortune, thanks to Fellowship fees and taxes. It’s worst for Paws folk, drivin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("supplies")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of here. Weston’s one of many there, barely survivin’, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his family—tragic. Figg’s arrest, pushed by the Fellowship, showed no care for his plight.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest proves they value control over kindness.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship funds some healing supplies, but their sway over Patterson and folk like Figg makes me doubt their true intentions.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou believest in their aid? They help some, but I’m wary.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Good to question ‘em. Their influence feels more like control.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Stay well, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0468