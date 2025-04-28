require "U7LuaFuncs"
-- func_0455.lua
-- Abraham's dialogue as a Fellowship member in Britain
local U7 = require("U7LuaFuncs")

function func_0455(eventid)
    local answers = {}
    local flag_00CB = U7.getFlag(0x00CB) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00DA = U7.getFlag(0x00DA) -- Recruitment topic
    local npc_id = -74 -- Abraham's NPC ID

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
        if flag_00DA then
            table.insert(answers, "recruitment")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00CB then
            U7.say("You see a confident man with a steady gaze, his Fellowship medallion prominently displayed.")
            U7.setFlag(0x00CB, true)
        else
            U7.say("\"Well met, \" .. U7.getPlayerName() .. \",\" Abraham says with a firm handshake.")
        end

        while true do
            if #answers == 0 then
                U7.say("Abraham nods warmly. \"What brings thee to the Fellowship today?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Abraham, proud member of the Fellowship, working under Batlin’s guidance.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I recruit new members for the Fellowship, spreading our message of unity. With Batlin and Elizabeth, we strengthen Britain, despite voices like Brownie’s.\"")
                table.insert(answers, "recruitment")
                table.insert(answers, "Batlin")
                table.insert(answers, "Brownie")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00DA, true)
            elseif choice == "recruitment" then
                U7.say("\"We seek those eager to unite Britannia, from nobles to workers. Even those like Weston could find purpose with us, had he chosen our path.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("recruitment")
            elseif choice == "Batlin" then
                U7.say("\"Batlin’s vision inspires us all. With Elizabeth, we carry his message, guiding Britain to harmony, unlike agitators like Brownie.\"")
                table.insert(answers, "Brownie")
                U7.RemoveAnswer("Batlin")
            elseif choice == "Brownie" then
                U7.say("\"Brownie’s campaign disrupts Britain’s progress. The Fellowship, with allies like Patterson, offers stability he cannot match.\"")
                table.insert(answers, "Patterson")
                U7.RemoveAnswer("Brownie")
            elseif choice == "Patterson" then
                U7.say("\"Mayor Patterson’s support ensures our work thrives. His leadership aligns with our goals, fostering order in Britain.\"")
                U7.RemoveAnswer("Patterson")
            elseif choice == "Weston" then
                U7.say("\"Weston’s fall was tragic, but Figg’s actions upheld order, as we advocate. The Fellowship could have lifted him from despair, had he joined us.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s vigilance, as seen with Weston, embodies our commitment to Britannia’s strength. He’s a model member of our cause.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship is Britannia’s future, uniting all under our banner. Join us, as many have, and find thy place in our vision.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thy interest honors us. Meet Batlin or Elizabeth to take the next step.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Hesitation is common. Speak with our members, and thou wilt see the light of our truth.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Seek the path of unity, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0455