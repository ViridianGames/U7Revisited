-- func_0482.lua
-- Thane's dialogue as a cooper in Britain


function func_0482(eventid)
    local answers = {}
    local flag_00E6 = get_flag(0x00E6) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00F5 = get_flag(0x00F5) -- Coopering topic
    local npc_id = -101 -- Thane's NPC ID

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
        if flag_00F5 then
            add_answer( "coopering")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00E6 then
            add_dialogue("You see a sturdy man hammering wood, his workshop stacked with barrels.")
            set_flag(0x00E6, true)
        else
            add_dialogue("\"Hail, \" .. get_player_name() .. \",\" Thane says, tightening a hoop.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Thane wipes his brow. \"Need a barrel or some talk?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Thane, cooper of Britain, craftin’ barrels for all.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I make barrels for wine, ale, and storage. The Fellowship’s trade deals bring timber, but their hold on Patterson’s got me concerned.\"")
                add_answer( "coopering")
                add_answer( "Fellowship")
                set_flag(0x00F5, true)
            elseif choice == "coopering" then
                add_dialogue("\"I craft sturdy barrels, but wood’s costly due to taxes. Folk like Weston can’t afford storage, and that’s causin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("coopering")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes drive up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—starvin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—sad tale. Figg’s arrest, backed by the Fellowship, was harsh, no mercy shown.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my shop stocked, but their ties to Patterson and Figg make me think they’re hammerin’ out more than just trade.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m watchin’ close.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence is heavier than a full barrel.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay strong, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0482