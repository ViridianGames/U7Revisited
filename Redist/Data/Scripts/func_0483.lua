-- func_0483.lua
-- Myra's dialogue as a florist in Britain


function func_0483(eventid)
    local answers = {}
    local flag_00E7 = get_flag(0x00E7) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00F6 = get_flag(0x00F6) -- Flowers topic
    local npc_id = -102 -- Myra's NPC ID

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
        if flag_00F6 then
            add_answer( "flowers")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00E7 then
            add_dialogue("You see a cheerful woman arranging flowers, her shop bursting with colorful blooms.")
            set_flag(0x00E7, true)
        else
            add_dialogue("\"Welcome, \" .. get_player_name() .. \",\" Myra says, trimming a stem.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Myra smiles brightly. \"Need a bouquet or some gossip?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Myra, florist of Britain, bringin’ beauty to all with my flowers.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I grow and sell flowers—roses, lilies, and more. The Fellowship’s trade deals bring seeds, but their hold on Patterson’s got me a bit wary.\"")
                add_answer( "flowers")
                add_answer( "Fellowship")
                set_flag(0x00F6, true)
            elseif choice == "flowers" then
                add_dialogue("\"My blooms brighten any day, but prices are high from taxes. Folk like Weston can’t afford a single rose, and that’s causin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("flowers")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes drive up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—such a pity. Figg’s arrest, backed by the Fellowship, was harsh, no kindness shown.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my shop bloomin’, but their ties to Patterson and Figg make me think they’re plantin’ more than just trade.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m keepin’ a close eye.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence is heavier than a bushel of roses.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Brighten thy day, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0483