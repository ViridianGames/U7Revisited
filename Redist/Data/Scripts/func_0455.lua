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
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Item interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00DA then
            add_answer( "recruitment")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00CB then
            add_dialogue("You see a confident man with a steady gaze, his Fellowship medallion prominently displayed.")
            set_flag(0x00CB, true)
        else
            add_dialogue("\"Well met, \" .. U7.getPlayerName() .. \",\" Abraham says with a firm handshake.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Abraham nods warmly. \"What brings thee to the Fellowship today?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Abraham, proud member of the Fellowship, working under Batlin’s guidance.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I recruit new members for the Fellowship, spreading our message of unity. With Batlin and Elizabeth, we strengthen Britain, despite voices like Brownie’s.\"")
                add_answer( "recruitment")
                add_answer( "Batlin")
                add_answer( "Brownie")
                add_answer( "Fellowship")
                set_flag(0x00DA, true)
            elseif choice == "recruitment" then
                add_dialogue("\"We seek those eager to unite Britannia, from nobles to workers. Even those like Weston could find purpose with us, had he chosen our path.\"")
                add_answer( "Weston")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("recruitment")
            elseif choice == "Batlin" then
                add_dialogue("\"Batlin’s vision inspires us all. With Elizabeth, we carry his message, guiding Britain to harmony, unlike agitators like Brownie.\"")
                add_answer( "Brownie")
                remove_answer("Batlin")
            elseif choice == "Brownie" then
                add_dialogue("\"Brownie’s campaign disrupts Britain’s progress. The Fellowship, with allies like Patterson, offers stability he cannot match.\"")
                add_answer( "Patterson")
                remove_answer("Brownie")
            elseif choice == "Patterson" then
                add_dialogue("\"Mayor Patterson’s support ensures our work thrives. His leadership aligns with our goals, fostering order in Britain.\"")
                remove_answer("Patterson")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s fall was tragic, but Figg’s actions upheld order, as we advocate. The Fellowship could have lifted him from despair, had he joined us.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s vigilance, as seen with Weston, embodies our commitment to Britannia’s strength. He’s a model member of our cause.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship is Britannia’s future, uniting all under our banner. Join us, as many have, and find thy place in our vision.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thy interest honors us. Meet Batlin or Elizabeth to take the next step.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Hesitation is common. Speak with our members, and thou wilt see the light of our truth.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Seek the path of unity, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0455