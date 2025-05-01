-- func_0473.lua
-- Elara's dialogue as a carpenter in Britain

function func_0473(eventid)
    local answers = {}
    local flag_00DD = get_flag(0x00DD) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00EC = get_flag(0x00EC) -- Carpentry topic
    local npc_id = -92 -- Elara's NPC ID

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
        if flag_00EC then
            add_answer( "carpentry")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00DD then
            add_dialogue("You see a sturdy woman sawing wood, her workshop filled with the scent of sawdust.")
            set_flag(0x00DD, true)
        else
            add_dialogue("\"Hail, \" .. get_player_name() .. \",\" Elara says, brushing off her hands.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Elara sets down her saw. \"Need furniture or a chat?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Elara, carpenter of Britain, buildin’ sturdy goods for all.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I craft tables, chairs, and more. The Fellowship’s trade deals bring timber, but their hold on Patterson’s got me questionin’.\"")
                add_answer( "carpentry")
                add_answer( "Fellowship")
                set_flag(0x00EC, true)
            elseif choice == "carpentry" then
                add_dialogue("\"I build solid furniture, but timber’s costly due to taxes. Folk like Weston can’t afford a chair, and that’s causin’ strife.\"")
                add_answer( "Weston")
                add_answer( "timber")
                remove_answer("carpentry")
            elseif choice == "timber" then
                add_dialogue("\"Timber from Yew’s pricey, thanks to Fellowship fees and taxes. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("timber")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—heartbreakin’. Figg’s arrest, backed by the Fellowship, was cold, no mercy shown.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their rules. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my workshop stocked, but their ties to Patterson and Figg make me think they’re buildin’ more than just trade.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m keepin’ an eye out.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Smart to doubt ‘em. Their influence is heavier than my hammer.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay sturdy, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0473