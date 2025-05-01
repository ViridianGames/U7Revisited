-- func_0449.lua
-- Nanna's dialogue as the nanny at Castle British


function func_0449(eventid)
    local answers = {}
    local flag_00C0 = get_flag(0x00C0) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00CF = get_flag(0x00CF) -- Children topic
    local npc_id = -63 -- Nanna's NPC ID

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
        if flag_00CF then
            add_answer( "children")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00C0 then
            add_dialogue("You see an elderly woman with a warm smile, knitting a tiny sweater.")
            set_flag(0x00C0, true)
        else
            add_dialogue("\"Good to see thee, \" .. get_player_name() .. \",\" Nanna says kindly.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Nanna sets down her knitting. \"What’s on thy mind, dear?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"I’m Nanna, nanny to the children of Castle British.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I care for the castle’s children—nobles’ heirs and servants’ little ones alike. I teach ‘em manners and keep ‘em out of trouble.\"")
                add_answer( "children")
                add_answer( "castle")
                set_flag(0x00CF, true)
            elseif choice == "children" then
                add_dialogue("\"They’re a lively bunch, full of spirit. But I worry about the older ones—some are drawn to the Fellowship’s promises.\"")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("children")
            elseif choice == "castle" then
                add_dialogue("\"Castle British is a grand place, but it’s not all feasts and finery. We servants work hard, and there’s always gossip to keep up with.\"")
                add_answer( "gossip")
                remove_answer("castle")
            elseif choice == "gossip" then
                add_dialogue("\"Oh, there’s talk of young Charles fancying Jeanette from the Blue Boar, and whispers of Fellowship folk meeting in the castle’s shadows.\"")
                add_answer( "Jeanette")
                add_answer( "Fellowship")
                remove_answer("gossip")
            elseif choice == "Jeanette" then
                add_dialogue("\"That lass at the Blue Boar’s caught Charles’s eye. He’s a good lad, but shy. I hope he finds the courage to speak to her.\"")
                set_flag(0x007B, true)
                remove_answer("Jeanette")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s got a way with words, luring in the young with talk of purpose. But I’ve seen their kind before—promises that hide agendas.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Mayhap I’m too old and cynical. I’ll ponder their ways.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Nay, I’ve raised enough children to know trouble when I see it.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Mind thy manners, \" .. get_player_name() .. \",\" Nanna says with a wink.")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0449