-- func_0467.lua
-- Wisp's dialogue as an alchemist in Britain


function func_0467(eventid)
    local answers = {}
    local flag_00D7 = get_flag(0x00D7) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00E6 = get_flag(0x00E6) -- Potions topic
    local npc_id = -86 -- Wisp's NPC ID

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
        if flag_00E6 then
            add_answer( "potions")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00D7 then
            add_dialogue("You see a focused man mixing vials, surrounded by bubbling potions in a cluttered shop.")
            set_flag(0x00D7, true)
        else
            add_dialogue("\"Greetings, \" .. get_player_name() .. \",\" Wisp says, stirring a potion.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Wisp sets down a vial. \"Need a potion or some insight?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Wisp, alchemist of Britain, brewin’ remedies and more.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I craft potions—healin’, sleep, you name it. The Fellowship’s trade deals get me herbs, but their hold on Patterson’s a bit worrisome.\"")
                add_answer( "potions")
                add_answer( "Fellowship")
                set_flag(0x00E6, true)
            elseif choice == "potions" then
                add_dialogue("\"Got salves for wounds, draughts for sleep. Herbs are costly, though—folk like Weston can’t afford ‘em, and that stirs trouble.\"")
                add_answer( "Weston")
                add_answer( "herbs")
                remove_answer("potions")
            elseif choice == "herbs" then
                add_dialogue("\"Herbs come from Yew and Moonglow, but Fellowship fees hike prices. It’s tough on Paws folk, pushin’ ‘em to desperation like Weston.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("herbs")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of here. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t seem to reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his family—heartbreakin’. Figg’s arrest, backed by the Fellowship, was swift, no pity given.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship loyalist, pushin’ their agenda. His role in Weston’s arrest shows they care more for order than folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s trade deals keep my shop stocked, but their ties to Patterson and Figg make me question what they’re really brewin’.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m keepin’ a sharp eye.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence feels like a potion gone wrong.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Mind thy health, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0467