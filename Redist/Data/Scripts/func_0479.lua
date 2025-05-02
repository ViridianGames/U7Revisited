-- func_0479.lua
-- Hal's dialogue as a tanner in Britain


function func_0479(eventid)
    local answers = {}
    local flag_00E3 = get_flag(0x00E3) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00F2 = get_flag(0x00F2) -- Tanning topic
    local npc_id = -98 -- Hal's NPC ID

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
        if flag_00F2 then
            add_answer( "tanning")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00E3 then
            add_dialogue("You see a rugged man scraping hides, his tannery pungent with the smell of leather.")
            set_flag(0x00E3, true)
        else
            add_dialogue("\"Ho, \" .. get_player_name() .. \",\" Hal says, wiping his hands.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Hal sets down a hide. \"Need leather or a word?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Hal, tanner of Britain, craftin’ fine leather for all.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I tan hides for leather—belts, boots, and more. The Fellowship’s trade deals bring hides, but their grip on Patterson’s got me suspicious.\"")
                add_answer( "tanning")
                add_answer( "Fellowship")
                set_flag(0x00F2, true)
            elseif choice == "tanning" then
                add_dialogue("\"I make tough leather, but hides are costly from taxes. Folk like Weston can’t afford a belt, and that’s stirrin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("tanning")
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
                add_dialogue("\"Weston stole apples to feed his kin—damn shame. Figg’s arrest, backed by the Fellowship, was cold, no mercy shown.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my tannery stocked, but their ties to Patterson and Figg make me think they’re tannin’ more than just hides.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m keepin’ a sharp eye.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence is heavier than a cured hide.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay tough, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0479