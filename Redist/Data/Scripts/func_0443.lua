-- func_0443.lua
-- Clint's dialogue as the shipwright in Britain


function func_0443(eventid)
    local answers = {}
    local flag_00BA = get_flag(0x00BA) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00CB = get_flag(0x00CB) -- Ships topic
    local npc_id = -57 -- Clint's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x08A6, 1) -- Buy interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00CB then
            add_answer( "ships")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00BA then
            add_dialogue("You see a weathered man with hands stained by pitch, inspecting a ship's hull.")
            set_flag(0x00BA, true)
        else
            add_dialogue("\"Ahoy, \" .. get_player_name() .. \"!\" Clint says with a wave.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Clint scratches his beard. \"Got more to discuss?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Clint, shipwright of Britain's docks.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I build and repair ships for merchants and adventurers. Need a vessel or a deed? I've got both.\"")
                add_answer( "ships")
                add_answer( "buy")
                set_flag(0x00CB, true)
            elseif choice == "ships" then
                add_dialogue("\"My ships are sturdy, built with timber from Yew. From small skiffs to galleons, they'll carry thee across Britannia's seas.\"")
                add_answer( "timber")
                remove_answer("ships")
            elseif choice == "timber" then
                add_dialogue("\"Yew's forests provide the best oak. Costs a fortune to ship it here, but no one's drowned in a Clint-built vessel yet.\"")
                remove_answer("timber")
            elseif choice == "buy" then
                add_dialogue("\"A ship's deed is 200 gold, a skiff's 50. What's thy fancy?\"")
                local response = call_extern(0x08A6, var_0001)
                if response == 0 then
                    local item_choice = get_answer({"ship", "skiff", "none"})
                    if item_choice == "ship" then
                        local gold_result = U7.removeGold(200)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 390)
                            if item_result then
                                add_dialogue("\"Here's the deed to thy ship. She's docked and ready!\"")
                            else
                                add_dialogue("\"Thou canst not carry the deed! Clear some space.\"")
                            end
                        else
                            add_dialogue("\"Thou lackest the gold for a ship.\"")
                        end
                    elseif item_choice == "skiff" then
                        local gold_result = U7.removeGold(50)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 391)
                            if item_result then
                                add_dialogue("\"Here's the deed to thy skiff. Small but swift!\"")
                            else
                                add_dialogue("\"Thou canst not carry the deed! Clear some space.\"")
                            end
                        else
                            add_dialogue("\"Thou lackest the gold for a skiff.\"")
                        end
                    else
                        add_dialogue("\"No sale? Come back when thou'rt ready to sail.\"")
                    end
                else
                    add_dialogue("\"Not sailing today? My docks are always open.\"")
                end
                remove_answer("buy")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship's been buying ships, claiming they're for 'spreading unity.' But I've seen their crews—look more like mercenaries than missionaries.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Maybe they're just traders. I'll keep watch.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Nay, something's fishy. I don't trust 'em.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Fair winds, \" .. get_player_name() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0443