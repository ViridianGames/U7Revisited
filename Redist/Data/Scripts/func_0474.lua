-- func_0474.lua
-- Jorin's dialogue as a fisherman in Britain


function func_0474(eventid)
    local answers = {}
    local flag_00DE = get_flag(0x00DE) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00ED = get_flag(0x00ED) -- Fishing topic
    local npc_id = -93 -- Jorin's NPC ID

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
        if flag_00ED then
            add_answer( "fishing")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00DE then
            add_dialogue("You see a weathered man mending nets, the smell of fish clinging to his clothes.")
            set_flag(0x00DE, true)
        else
            add_dialogue("\"Hail, \" .. get_player_name() .. \",\" Jorin says, knotting a rope.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Jorin squints at you. \"Need fish or a yarn from the docks?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Jorin, fisherman of Britain's waters, haulin' in the day's catch.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I fish the seas for Britain's markets. The Fellowship's trade deals help sell my catch, but their grip on Patterson's got me uneasy.\"")
                add_answer( "fishing")
                add_answer( "Fellowship")
                set_flag(0x00ED, true)
            elseif choice == "fishing" then
                add_dialogue("\"I pull in cod and herring, but prices are high from taxes. Folk like Weston can't afford a fish, and that's stirrin' trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("fishing")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes drive up my costs. It's worst for Paws folk, pushin' ‘em to acts like Weston's.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston's from there—starvin' folk, and the Fellowship's aid don't reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—sad tale. Figg's arrest, backed by the Fellowship, was harsh, no mercy for the desperate.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg's a Fellowship man, pushin' their order. His role in Weston's arrest shows they care more for control than folk like us.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship's deals get my fish to market, but their ties to Patterson and Figg make me think they're castin' a wider net than trade.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I'm watchin' ‘em close.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Smart to doubt ‘em. Their influence is heavier than a full net.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Fair winds, " .. get_player_name() .. ".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0474