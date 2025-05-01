-- func_0452.lua
-- Patterson's dialogue as the mayor of Britain


function func_0452(eventid)
    local answers = {}
    local flag_00C8 = get_flag(0x00C8) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00D7 = get_flag(0x00D7) -- Governance topic
    local npc_id = -71 -- Patterson's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x090A, 1) -- Item interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00D7 then
            add_answer( "governance")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00C8 then
            add_dialogue("You see a polished man in fine attire, exuding confidence but with a guarded smile.")
            set_flag(0x00C8, true)
        else
            add_dialogue("\"Welcome, \" .. get_player_name() .. \",\" Patterson says with a practiced nod.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Patterson adjusts his cloak. \"What business hast thou with Britain’s mayor?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Patterson, mayor of Britain, serving its people with pride.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I govern Britain, ensuring its prosperity and order. The Fellowship aids my efforts, though some, like that farmer Brownie, challenge my rule.\"")
                add_answer( "governance")
                add_answer( "Brownie")
                add_answer( "Fellowship")
                set_flag(0x00D7, true)
            elseif choice == "governance" then
                add_dialogue("\"Running Britain demands strength. Taxes fund our growth, and the Fellowship’s support keeps order, despite rabble-rousers like Brownie.\"")
                add_answer( "Brownie")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("governance")
            elseif choice == "Brownie" then
                add_dialogue("\"Brownie’s a farmer stirring trouble with his mayoral campaign. He claims I favor the Fellowship, but his ideas would bankrupt Britain.\"")
                add_answer( "Fellowship")
                remove_answer("Brownie")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship brings unity and progress. Their guidance strengthens Britain, though some distrust them. I find their vision aligns with mine.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou seest their value? Good. They’re key to Britain’s future.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Distrust them? Speak to their leaders—thou wilt see their worth.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Fare well, \" .. get_player_name() .. \". Support Britain’s progress.\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0452