-- func_0470.lua
-- Markus's dialogue as a blacksmith in Britain


function func_0470(eventid)
    local answers = {}
    local flag_00DA = get_flag(0x00DA) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00E9 = get_flag(0x00E9) -- Forge topic
    local npc_id = -89 -- Markus's NPC ID

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
        if flag_00E9 then
            add_answer( "forge")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00DA then
            add_dialogue("You see a burly man hammering iron, sparks flying in his smoky forge.")
            set_flag(0x00DA, true)
        else
            add_dialogue("\"Ho, \" .. get_player_name() .. \",\" Markus says, wiping sweat from his brow.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Markus sets down his hammer. \"Need a blade or some talk?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Markus, blacksmith of Britain, forgin’ steel for all.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I forge swords, tools, and armor. The Fellowship’s trade deals bring iron, but their hold on Patterson’s got me suspicious.\"")
                add_answer( "forge")
                add_answer( "Fellowship")
                set_flag(0x00E9, true)
            elseif choice == "forge" then
                add_dialogue("\"My forge runs hot, but iron’s pricey due to taxes. Folk like Weston can’t afford tools, and that’s sparkin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("forge")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes drive up my costs. It’s roughest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of here. Weston’s from there—starvin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—damn shame. Figg’s arrest, backed by the Fellowship, was cold, no mercy.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their rules. His part in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my forge stocked, but their ties to Patterson and Figg make me think they’re hammerin’ out more than just trade.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m keepin’ my eye on ‘em.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Smart to question ‘em. Their influence is heavier than my anvil.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay sharp, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end
-- func_0470.lua