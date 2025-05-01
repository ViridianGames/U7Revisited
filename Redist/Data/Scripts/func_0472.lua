-- func_0472.lua
-- Torwin's dialogue as a stablemaster in Britain


function func_0472(eventid)
    local answers = {}
    local flag_00DC = get_flag(0x00DC) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00EB = get_flag(0x00EB) -- Stables topic
    local npc_id = -91 -- Torwin's NPC ID

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
        if flag_00EB then
            add_answer( "stables")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00DC then
            add_dialogue("You see a rugged man brushing a horse, his stables filled with the scent of hay.")
            set_flag(0x00DC, true)
        else
            add_dialogue("\"Hail, \" .. get_player_name() .. \",\" Torwin says, tossing a pitchfork aside.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Torwin leans against a stall. \"Need a horse or some talk?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Torwin, stablemaster of Britain, tendin’ to the finest steeds.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I run the stables, sellin’ horses and feed. The Fellowship’s trade deals bring hay, but their sway over Patterson’s got me wary.\"")
                add_answer( "stables")
                add_answer( "Fellowship")
                set_flag(0x00EB, true)
            elseif choice == "stables" then
                add_dialogue("\"Got strong horses and fresh feed, but prices are high. Folk like Weston can’t afford even a mule, and that’s stirrin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("stables")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes jack up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—damn shame. Figg’s arrest, backed by the Fellowship, was harsh, no heart in it.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they care more for control than folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my stables stocked, but their ties to Patterson and Figg make me think they’re ridin’ for more than just trade.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m keepin’ a sharp eye.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Smart to doubt ‘em. Their influence is heavier than a warhorse.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Ride safe, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0472