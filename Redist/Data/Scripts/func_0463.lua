-- func_0463.lua
-- Sean's dialogue as a jeweler in Britain


function func_0463(eventid)
    local answers = {}
    local flag_00D3 = get_flag(0x00D3) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00E2 = get_flag(0x00E2) -- Jewelry topic
    local npc_id = -82 -- Sean's NPC ID

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
        if flag_00E2 then
            add_answer( "jewelry")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00D3 then
            add_dialogue("You see a meticulous man polishing a gem, his shop gleaming with fine jewelry.")
            set_flag(0x00D3, true)
        else
            add_dialogue("\"Good to see thee, \" .. get_player_name() .. \",\" Sean says, setting down a ring.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Sean smiles. \"Care to browse my wares or chat?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Sean, jeweler of Britain, crafting beauty for the discerning.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I craft and sell jewelry—rings, necklaces, the lot. The Fellowship’s trade deals help, but their grip on folk like Patterson concerns me.\"")
                add_answer( "jewelry")
                add_answer( "Fellowship")
                set_flag(0x00E2, true)
            elseif choice == "jewelry" then
                add_dialogue("\"My gems come from Minoc, but taxes make ‘em pricey. Poor folk like Weston can’t afford such luxuries, and that breeds trouble.\"")
                add_answer( "Weston")
                add_answer( "Minoc")
                remove_answer("jewelry")
            elseif choice == "Minoc" then
                add_dialogue("\"Minoc’s mines supply my gems, but the Fellowship’s trade rules raise costs. It’s harder for honest folk to get by.\"")
                add_answer( "Fellowship")
                remove_answer("Minoc")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his family—sad case. Figg’s quick arrest, pushed by the Fellowship, showed no mercy.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship loyalist, enforcin’ their order. His role in Weston’s case makes me question their so-called unity.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals boost commerce, but their hold over Patterson and push for control makes me wary of their true aims.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest their ways? They aid trade, but I watch ‘em closely.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Good to stay cautious. Their influence runs deeper than they let on.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Come back anytime, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0463