-- func_043E.lua
-- Brownie's dialogue as a farmer and mayoral candidate in Britain


function func_043E(eventid)
    local answers = {}
    local flag_00B5 = get_flag(0x00B5) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00C7 = get_flag(0x00C7) -- Campaign topic
    local npc_id = -52 -- Brownie's NPC ID

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
        if flag_00C7 then
            add_answer( "campaign")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00B5 then
            add_dialogue("You see a sturdy farmer with calloused hands and a hopeful smile.")
            set_flag(0x00B5, true)
        else
            add_dialogue("\"Well met, \" .. get_player_name() .. \"!\" Brownie says cheerfully.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Brownie nods. \"Anything else I can help thee with?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"I’m Brownie, farmer and candidate for mayor of Britain.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I farm the fields north of Britain—potatoes, carrots, and the like. Also running for mayor to make things fairer for folk like me.\"")
                add_answer( "farming")
                add_answer( "mayor")
            elseif choice == "farming" then
                add_dialogue("\"It’s honest work. Sunup to sundown, tending crops. I sell my produce at market, but prices are tight with taxes so high.\"")
                add_answer( "taxes")
                add_answer( "market")
                remove_answer("farming")
            elseif choice == "market" then
                add_dialogue("\"Britain’s market is bustling, but the fees to sell there eat into my earnings. If I’m mayor, I’ll lower those fees for farmers.\"")
                remove_answer("market")
            elseif choice == "taxes" then
                add_dialogue("\"Lord British means well, but his taxes hit small farmers hard. The Fellowship’s been pushing for exemptions, but only for their own.\"")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("taxes")
            elseif choice == "mayor" then
                add_dialogue("\"I’m running for mayor to give the common folk a voice. Britain’s run by nobles and guilds, but farmers and workers deserve better.\"")
                add_answer( "campaign")
                set_flag(0x00C7, true)
                remove_answer("mayor")
            elseif choice == "campaign" then
                add_dialogue("\"My campaign’s about fairness. Lower taxes, fewer fees, and less influence from groups like the Fellowship. I’ve got support from farmers, but the nobles aren’t keen.\"")
                add_answer( "support")
                remove_answer("campaign")
            elseif choice == "support" then
                add_dialogue("\"Folks in Paws and the fields back me, but I need more votes in Britain. If thou couldst spread the word, I’d be grateful.\"")
                local response = call_extern(0x090A, var_0001)
                if response == 0 then
                    add_dialogue("\"Thou’lt help? Bless thee! Here’s a carrot from my fields.\"")
                    local item_result = U7.giveItem(16, 1, 383)
                    if not item_result then
                        add_dialogue("\"Oh, thou art too laden to carry it. Clear some space!\"")
                    end
                else
                    add_dialogue("\"No matter, I’ll keep at it.\"")
                end
                remove_answer("support")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship claims to help all, but they favor their own. I’ve seen them pressure farmers to join or face trouble at market. I don’t trust ‘em.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Maybe I’m too harsh. I’ll think on their ideas.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Nay, I’ve seen enough to know they’re not for me.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Vote for Brownie, \" .. get_player_name() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_043E