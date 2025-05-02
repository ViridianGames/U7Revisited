-- func_0460.lua
-- Finn's dialogue as a beggar in Britain


function func_0460(eventid)
    local answers = {}
    local flag_00D0 = get_flag(0x00D0) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00DF = get_flag(0x00DF) -- Poverty topic
    local npc_id = -79 -- Finn's NPC ID

    if eventid == 1 then
        switch_talk_to(npc_id, 0)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x090A, 1) -- Item interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00DF then
            add_answer( "poverty")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00D0 then
            add_dialogue("You see a ragged man with weary eyes, clutching a worn cup for coins.")
            set_flag(0x00D0, true)
        else
            add_dialogue("\"Thou’rt back, \" .. get_player_name() .. \",\" Finn mutters, shivering.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Finn coughs. \"Spare a word or a coin for a poor soul?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Finn, just a beggar, forgotten by most in Britain.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"Ain’t got no job. I beg to eat, like others in Paws. The Fellowship promises help, but I seen none.\"")
                add_answer( "poverty")
                add_answer( "Fellowship")
                set_flag(0x00DF, true)
            elseif choice == "poverty" then
                add_dialogue("\"Paws is starvin’, like me. Folk like Weston tried to feed their kin, and look where it got ‘em—jailed by Figg.\"")
                add_answer( "Weston")
                add_answer( "Figg")
                remove_answer("poverty")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s a mate from Paws, nabbed for stealin’ apples. He was desperate, like me. Figg and the Fellowship didn’t care.\"")
                add_answer( "Figg")
                add_answer( "Fellowship")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a cruel one, workin’ with the Fellowship. He turned Weston in without a thought, all to please ‘em.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship talks big—unity, help for all—but I ain’t seen a coin from ‘em. They’re all smiles for Patterson, not us beggars.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou think they’re kind? Maybe, but they pass me by every day.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Aye, don’t trust ‘em. They’re up to somethin’, mark my words.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Spare a coin someday, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0460