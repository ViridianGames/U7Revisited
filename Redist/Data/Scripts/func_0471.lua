-- func_0471.lua
-- Anya's dialogue as an innkeeper in Britain


function func_0471(eventid)
    local answers = {}
    local flag_00DB = get_flag(0x00DB) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00EA = get_flag(0x00EA) -- Inn topic
    local npc_id = -90 -- Anya's NPC ID

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
        if flag_00EA then
            add_answer( "inn")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00DB then
            add_dialogue("You see a welcoming woman cleaning mugs, her inn cozy with the hum of travelers.")
            set_flag(0x00DB, true)
        else
            add_dialogue("\"Good to see thee, \" .. get_player_name() .. \",\" Anya says, pouring a drink.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Anya leans on the counter. \"Need a room or some gossip?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Anya, innkeeper of Britain’s finest rest stop.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I run this inn, offerin’ beds and ale to travelers. The Fellowship’s trade deals keep my pantry full, but their sway over Patterson’s a bit much.\"")
                add_answer( "inn")
                add_answer( "Fellowship")
                set_flag(0x00EA, true)
            elseif choice == "inn" then
                add_dialogue("\"Got cozy rooms and hearty stew, but prices ain’t cheap. Folk like Weston can’t afford a night here, and that’s causin’ strife.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("inn")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes raise my rates. It’s toughest on Paws folk, drivin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—heart-wrenchin’. Figg’s arrest, pushed by the Fellowship, was harsh, no care for his troubles.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, all about their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my inn stocked, but their ties to Patterson and folk like Figg make me wonder what they’re really plottin’.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m watchin’ close.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence feels heavier than their promises.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Rest well, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0471