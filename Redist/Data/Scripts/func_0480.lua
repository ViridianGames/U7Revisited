-- func_0480.lua
-- Verna's dialogue as a baker's apprentice in Britain


function func_0480(eventid)
    local answers = {}
    local flag_00E4 = get_flag(0x00E4) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00F3 = get_flag(0x00F3) -- Bakery topic
    local npc_id = -99 -- Verna's NPC ID

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
        if flag_00F3 then
            add_answer( "bakery")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00E4 then
            add_dialogue("You see a young woman kneading dough, her apron dusted with flour in a bustling bakery.")
            set_flag(0x00E4, true)
        else
            add_dialogue("\"Hail, \" .. get_player_name() .. \",\" Verna says, shaping a loaf.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Verna wipes her hands. \"Want bread or a quick chat?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Verna, apprentice baker, learnin’ the trade in Britain.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I’m learnin’ to bake bread and pastries. The Fellowship’s trade deals bring flour, but their sway over Patterson’s got folk talkin’.\"")
                add_answer( "bakery")
                add_answer( "Fellowship")
                set_flag(0x00F3, true)
            elseif choice == "bakery" then
                add_dialogue("\"We bake fresh loaves daily, but prices are high. Folk like Weston can’t afford bread, and that’s causin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("bakery")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes make flour costly. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—such a shame. Figg’s arrest, backed by the Fellowship, was harsh, no heart in it.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their rules. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep our ovens goin’, but their ties to Patterson and Figg make me think they’re kneadin’ a bigger plan than trade.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m watchin’ close.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence is heavier than a sack of flour.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Enjoy thy day, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0480