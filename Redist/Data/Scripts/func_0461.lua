-- func_0461.lua
-- Garritt's dialogue as a merchant in Britain


function func_0461(eventid)
    local answers = {}
    local flag_00D1 = get_flag(0x00D1) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00E0 = get_flag(0x00E0) -- Trade topic
    local npc_id = -80 -- Garritt's NPC ID

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
        if flag_00E0 then
            add_answer( "trade")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00D1 then
            add_dialogue("You see a well-dressed man with a ledger, overseeing crates in Britain’s market.")
            set_flag(0x00D1, true)
        else
            add_dialogue("\"Back again, \" .. get_player_name() .. \"?\" Garritt says, tallying his wares.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Garritt glances up. \"What’s thy business in the market?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Garritt, merchant of Britain’s finest goods.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I trade goods in Britain’s market, from cloth to grain. The Fellowship’s push for unity aids business, but their fees sting.\"")
                add_answer( "trade")
                add_answer( "Fellowship")
                set_flag(0x00E0, true)
            elseif choice == "trade" then
                add_dialogue("\"Trade’s brisk, but taxes and Fellowship dues cut deep. Folk like Weston suffer most—poverty drives ‘em to desperate acts.\"")
                add_answer( "Weston")
                add_answer( "Fellowship")
                remove_answer("trade")
            elseif choice == "Weston" then
                add_dialogue("\"Weston, that poor sod, stole apples to feed his kin. Figg’s harsh justice, backed by the Fellowship, crushed him.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, all about order. His role in Weston’s arrest shows their influence over Britain’s laws.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship boosts trade with their talk of unity, but their dues and ties to Patterson make me wonder what they’re really after.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou thinkest them fair? Mayhap, but their fees hit my purse hard.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Aye, I don’t fully trust ‘em either. Something’s off with their plans.\"")
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

return func_0461