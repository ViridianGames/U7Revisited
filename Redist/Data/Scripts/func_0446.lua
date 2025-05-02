-- func_0446.lua
-- Nell's dialogue as a servant at Castle British


function func_0446(eventid)
    local answers = {}
    local flag_00BD = get_flag(0x00BD) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00CE = get_flag(0x00CE) -- Castle topic
    local npc_id = -60 -- Nell's NPC ID

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
        if flag_00CE then
            add_answer( "castle")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00BD then
            add_dialogue("You see a young woman in a crisp apron, polishing silverware with practiced ease.")
            set_flag(0x00BD, true)
        else
            add_dialogue("\"Hello again, \" .. get_player_name() .. \",\" Nell says with a curtsy.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Nell pauses her work. \"Need something else, milord?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"I’m Nell, servant to Lord British.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I clean, cook, and tend to the castle’s needs. It’s hard work, but I’m proud to serve His Majesty.\"")
                add_answer( "castle")
                add_answer( "Lord British")
                set_flag(0x00CE, true)
            elseif choice == "castle" then
                add_dialogue("\"Castle British is grand, but it’s a maze of halls and duties. I’ve worked here since I was a girl, and I still get lost sometimes.\"")
                add_answer( "duties")
                remove_answer("castle")
            elseif choice == "duties" then
                add_dialogue("\"Polishing silver, scrubbing floors, and helping in the kitchens. Keeps me busy, but I hear all the castle gossip.\"")
                add_answer( "gossip")
                remove_answer("duties")
            elseif choice == "Lord British" then
                add_dialogue("\"His Majesty is kind but busy. I rarely see him, though he always thanks us servants when he does. Some say he’s troubled by the Fellowship’s growing influence.\"")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("Lord British")
            elseif choice == "gossip" then
                add_dialogue("\"Oh, there’s always talk! Servants whisper about strange visitors to the castle—Fellowship folk, mostly, meeting with advisors late at night.\"")
                add_answer( "Fellowship")
                remove_answer("gossip")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s everywhere in Britain now. They’re polite, but I don’t like how they watch everyone. Makes my skin crawl.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Perhaps I’m being unfair. I’ll think on it.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Nay, I trust my instincts. They’re up to something.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Farewell, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0446