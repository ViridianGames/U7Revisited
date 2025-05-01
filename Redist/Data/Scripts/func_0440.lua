-- func_0440.lua
-- Kessler's dialogue as the apothecary in Britain


function func_0440(eventid)
    local answers = {}
    local flag_00B7 = get_flag(0x00B7) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00C8 = get_flag(0x00C8) -- Health topic
    local npc_id = -54 -- Kessler's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x08A3, 1) -- Buy interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00C8 then
            add_answer( "health")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00B7 then
            add_dialogue("You see a thin man with tired eyes, surrounded by vials and herbs, coughing softly.")
            set_flag(0x00B7, true)
        else
            add_dialogue("\"Greetings, \" .. get_player_name() .. \",\" Kessler says, stifling a cough.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Kessler adjusts a vial. \"Need something else?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"I’m Kessler, apothecary of Britain.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I craft potions and remedies for the sick. From fevers to wounds, I’ve something for most ailments. Need a potion?\"")
                add_answer( "remedies")
                add_answer( "buy")
                set_flag(0x00C8, true)
            elseif choice == "remedies" then
                add_dialogue("\"My salves heal cuts, my draughts cure sleeplessness, and my tonics ease pain. Each is made with care, though some herbs are scarce now.\"")
                add_answer( "herbs")
                remove_answer("remedies")
            elseif choice == "herbs" then
                add_dialogue("\"I source mandrake from Moonglow and ginseng from the Deep Forest, but supplies are tight. The Fellowship’s been buying up stocks, I hear.\"")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("herbs")
            elseif choice == "buy" then
                add_dialogue("\"A healing potion’s 15 gold, a tonic’s 10. What’ll it be?\"")
                local response = call_extern(0x08A3, var_0001)
                if response == 0 then
                    local item_choice = get_answer({"potion", "tonic", "none"})
                    if item_choice == "potion" then
                        local gold_result = U7.removeGold(15)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 384)
                            if item_result then
                                add_dialogue("\"Here’s thy healing potion. Use it wisely.\"")
                            else
                                add_dialogue("\"Thou canst not carry the potion! Lighten thy load.\"")
                            end
                        else
                            add_dialogue("\"Thou lackest the gold for a potion.\"")
                        end
                    elseif item_choice == "tonic" then
                        local gold_result = U7.removeGold(10)
                        if gold_result then
                            local item_result = U7.giveItem(16, 1, 385)
                            if item_result then
                                add_dialogue("\"Here’s a tonic to ease thy pains.\"")
                            else
                                add_dialogue("\"Thou canst not carry the tonic! Lighten thy load.\"")
                            end
                        else
                            add_dialogue("\"Thou lackest the gold for a tonic.\"")
                        end
                    else
                        add_dialogue("\"Changed thy mind? Fair enough.\"")
                    end
                else
                    add_dialogue("\"Come back when thou art ready.\"")
                end
                remove_answer("buy")
            elseif choice == "health" then
                add_dialogue("\"Jesamine worries, but it’s just a cough. Been mixing potions too long, breathing in fumes. I’ll be fine, though I could use a better remedy.\"")
                add_answer( "remedy")
                remove_answer("health")
            elseif choice == "remedy" then
                add_dialogue("\"If thou knowest a healer or a rare herb—like nightshade from Skara Brae—I’d pay well. My own stocks are low.\"")
                local item_check = U7.hasItem(16, 1, 386)
                if item_check then
                    local trade_result = U7.removeItem(16, 1, 386)
                    if trade_result then
                        local gold_result = U7.giveGold(50)
                        if gold_result then
                            add_dialogue("\"Nightshade! Thou’rt a lifesaver! Here’s 50 gold for thy trouble.\"")
                        else
                            add_dialogue("\"I’d pay thee, but thy purse is too full!\"")
                        end
                    end
                else
                    add_dialogue("\"No nightshade? If thou findest some, bring it to me.\"")
                end
                remove_answer("remedy")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s been sniffing around, offering to fund my shop. But I’ve heard they expect loyalty in return. I’d rather keep my freedom.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Perhaps they’re not so bad. I’ll hear them out.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Nay, I’ll stay clear. Too many strings attached.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay healthy, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0440