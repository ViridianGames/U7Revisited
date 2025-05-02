-- func_0445.lua
-- Judith's dialogue as the musician in Britain


function func_0445(eventid)
    local answers = {}
    local flag_00BC = get_flag(0x00BC) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00CD = get_flag(0x00CD) -- Music topic
    local npc_id = -59 -- Judith's NPC ID

    if eventid == 1 then
        switch_talk_to(npc_id, 0)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x08A8, 1) -- Performance interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00CD then
            add_answer( "music")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00BC then
            add_dialogue("You see a lively woman tuning a lute, her fingers dancing over the strings.")
            set_flag(0x00BC, true)
        else
            add_dialogue("\"Well met, \" .. get_player_name() .. \"!\" Judith says with a smile.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Judith strums a chord. \"Got more to chat about?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Judith, musician and bard of Britain.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I play music at the Blue Boar and other taverns. My tunes lift spirits, and I hear all the town’s gossip. Want to hear a song?\"")
                add_answer( "music")
                add_answer( "gossip")
                set_flag(0x00CD, true)
            elseif choice == "music" then
                add_dialogue("\"I play ballads, jigs, and laments. My lute’s my companion, crafted in New Magincia. Come to the Blue Boar tonight, and I’ll play for thee.\"")
                add_answer( "Blue Boar")
                remove_answer("music")
            elseif choice == "Blue Boar" then
                add_dialogue("\"It’s Britain’s liveliest tavern. Lucy runs it, and Jeanette serves the drinks. My music keeps the crowd merry, though some folk drink too much.\"")
                remove_answer("Blue Boar")
            elseif choice == "gossip" then
                add_dialogue("\"Plenty of talk at the tavern. Some say the Fellowship’s behind recent thefts, but they’re all smiles when they drink. Hard to know what’s true.\"")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("gossip")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s got a following here, but I’ve heard whispers they pressure folk to join. They tip well at the tavern, though, so I keep my lute strummin’.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Maybe they’re not so bad. I’ll keep an ear out.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Nay, I’d rather sing than join their chorus.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Keep a song in thy heart, \" .. get_player_name() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0445