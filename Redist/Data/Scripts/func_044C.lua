-- func_044C.lua
-- Geoffrey's dialogue as the captain of the guard in Britain


function func_044C(eventid)
    local answers = {}
    local flag_00C2 = get_flag(0x00C2) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00D1 = get_flag(0x00D1) -- Security topic
    local npc_id = -65 -- Geoffrey's NPC ID

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
        if flag_00D1 then
            add_answer( "security")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00C2 then
            add_dialogue("You see a stern man in polished armor, his gaze sharp as he surveys the castle grounds.")
            set_flag(0x00C2, true)
        else
            add_dialogue("\"Hail, \" .. get_player_name() .. \",\" Geoffrey says with a crisp salute.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Geoffrey straightens. \"What business hast thou with me?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Geoffrey, captain of Lord British’s guard.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I command the castle guard, ensuring the safety of Lord British and Britannia’s heart. Crime’s rising, though, and my men are stretched thin.\"")
                add_answer( "security")
                add_answer( "crime")
                set_flag(0x00D1, true)
            elseif choice == "security" then
                add_dialogue("\"The castle’s fortified, but I’ve doubled patrols. Strange visitors—Fellowship folk, mostly—come and go at odd hours. I trust them not.\"")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("security")
            elseif choice == "crime" then
                add_dialogue("\"Thefts and brawls are up in Britain. Some prisoners, like that Weston fellow, claim desperation, but I suspect organized trouble. The Fellowship’s name keeps surfacing.\"")
                add_answer( "Weston")
                add_answer( "Fellowship")
                remove_answer("crime")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s in jail for stealing apples. Figg pushed hard for his arrest. I pity the man’s family, but the law’s the law.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a loyal servant, but his zeal borders on cruelty. He’s tight with the Fellowship, which makes me question his motives.\"")
                add_answer( "Fellowship")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s influence grows, and I mislike their secrecy. They’ve offered to ‘aid’ my guards, but I’ll not have outsiders meddling in castle affairs.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou thinkest them trustworthy? I’ll keep an open mind, but my eyes are sharper.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Good. Stay wary, Avatar. They’re not what they seem.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay vigilant, \" .. get_player_name() .. \". Britannia counts on thee.\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_044C