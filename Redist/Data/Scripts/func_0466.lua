-- func_0466.lua
-- Gaylen's dialogue as a baker in Britain


function func_0466(eventid)
    local answers = {}
    local flag_00D6 = get_flag(0x00D6) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00E5 = get_flag(0x00E5) -- Bakery topic
    local npc_id = -85 -- Gaylen's NPC ID

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
        if flag_00E5 then
            add_answer( "bakery")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00D6 then
            add_dialogue("You see a stout man kneading dough, the warm scent of bread filling his bakery.")
            set_flag(0x00D6, true)
        else
            add_dialogue("\"Hail, \" .. get_player_name() .. \",\" Gaylen says, dusting flour off his hands.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Gaylen wipes his brow. \"Fancy a loaf or a chat?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Gaylen, baker of Britain’s best bread and pastries.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I bake bread, rolls, and sweets for Britain. The Fellowship’s trade deals bring grain, but their sway over Patterson makes me uneasy.\"")
                add_answer( "bakery")
                add_answer( "Fellowship")
                set_flag(0x00E5, true)
            elseif choice == "bakery" then
                add_dialogue("\"My loaves are fresh daily, but prices are high from taxes. Folk like Weston can’t afford bread, and that’s a recipe for trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("bakery")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes jack up my costs. It’s hardest on Paws folk, pushin’ ‘em to desperate acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—starvin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—gut-wrenchin’. Figg’s arrest, with Fellowship backin’, was harsh, no mercy shown.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s tied to the Fellowship, enforcin’ their order. His role in Weston’s arrest shows they value control over compassion.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s grain deals keep my ovens hot, but their hold on Patterson and folk like Figg makes me wonder what they’re really bakin’.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They help trade, but I’m keepin’ my eyes peeled.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Good call, questionin’ ‘em. Their influence feels heavier than their promises.\"")
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

return func_0466