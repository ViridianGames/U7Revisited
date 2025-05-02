-- func_0447.lua
-- Charles's dialogue as a servant at Castle British


function func_0447(eventid)
    local answers = {}
    local flag_00BE = get_flag(0x00BE) -- First meeting
    local flag_007B = get_flag(0x007B) -- Jeanette topic
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local npc_id = -61 -- Charles's NPC ID

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
        if flag_007B then
            add_answer( "Jeanette")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00BE then
            add_dialogue("You see a young man in a neatly pressed uniform, carrying a tray of goblets.")
            set_flag(0x00BE, true)
        else
            add_dialogue("\"Greetings, \" .. get_player_name() .. \",\" Charles says with a polite nod.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Charles balances his tray. \"Anything else I can assist with?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Charles, at thy service. I’m a servant in Castle British.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I serve Lord British, tending to the castle’s guests and keeping things orderly. It’s long hours, but I enjoy it.\"")
                add_answer( "castle")
                add_answer( "guests")
            elseif choice == "castle" then
                add_dialogue("\"Castle British is a marvel, full of history. But it’s a lot to clean, and we’re always busy with visitors.\"")
                add_answer( "visitors")
                remove_answer("castle")
            elseif choice == "guests" then
                add_dialogue("\"We host nobles, advisors, and lately, a lot of Fellowship members. They’re polite, but they keep to themselves.\"")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("guests")
            elseif choice == "visitors" then
                add_dialogue("\"Some guests are kind, others demanding. I hear plenty of gossip, though—keeps the work interesting.\"")
                add_answer( "gossip")
                remove_answer("visitors")
            elseif choice == "gossip" then
                add_dialogue("\"There’s talk of Jeanette at the Blue Boar fancying someone. I… well, I hope it’s me, but I’m too shy to ask her.\"")
                add_answer( "Jeanette")
                set_flag(0x007B, true)
                remove_answer("gossip")
            elseif choice == "Jeanette" then
                add_dialogue("\"She’s the loveliest lass at the Blue Boar. I’ve seen her smile at me, but I’m just a servant. Do… do you think she’d fancy someone like me?\"")
                local response = call_extern(0x090A, var_0001)
                if response == 0 then
                    add_dialogue("\"Thou thinkest so? Oh, I’ll muster the courage to speak to her!\"")
                else
                    add_dialogue("\"Aye, I feared as much. I’ll keep my hopes low.\"")
                end
                remove_answer("Jeanette")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s been meeting with Lord British’s advisors. They talk of unity, but their eyes are always watching, like they’re sizing everyone up.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Maybe I’m wrong about them. I’ll listen more closely.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Nay, I don’t trust their smooth words.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Safe travels, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0447