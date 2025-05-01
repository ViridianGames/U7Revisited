-- func_0468.lua
-- Carlyn's dialogue as a healer in Britain


function func_0468(eventid)
    local answers = {}
    local flag_00D8 = get_flag(0x00D8) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00E7 = get_flag(0x00E7) -- Healing topic
    local npc_id = -87 -- Carlyn's NPC ID

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
        if flag_00E7 then
            add_answer( "healing")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00D8 then
            add_dialogue("You see a gentle woman tending to a patient, her hands steady with care.")
            set_flag(0x00D8, true)
        else
            add_dialogue("\"Welcome, \" .. get_player_name() .. \",\" Carlyn says, offering a kind smile.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Carlyn cleans a bandage. \"Need aid or just a word?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Carlyn, healer of Britain, tendin’ to the sick and weary.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I heal wounds and ailments for Britain’s folk. The Fellowship offers aid, but their influence on Patterson troubles me.\"")
                add_answer( "healing")
                add_answer( "Fellowship")
                set_flag(0x00E7, true)
            elseif choice == "healing" then
                add_dialogue("\"I treat cuts, fevers, and more, but supplies are costly. Poor folk like Weston can’t afford care, and that breeds despair.\"")
                add_answer( "Weston")
                add_answer( "supplies")
                remove_answer("healing")
            elseif choice == "supplies" then
                add_dialogue("\"Herbs and bandages cost a fortune, thanks to Fellowship fees and taxes. It’s worst for Paws folk, drivin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("supplies")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of here. Weston’s one of many there, barely survivin’, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his family—tragic. Figg’s arrest, pushed by the Fellowship, showed no care for his plight.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest proves they value control over kindness.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship funds some healing supplies, but their sway over Patterson and folk like Figg makes me doubt their true intentions.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou believest in their aid? They help some, but I’m wary.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Good to question ‘em. Their influence feels more like control.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay well, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0468