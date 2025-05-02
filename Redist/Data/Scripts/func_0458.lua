-- func_0458.lua
-- Candice's dialogue as a Fellowship treasurer in Britain


function func_0458(eventid)
    local answers = {}
    local flag_00CE = get_flag(0x00CE) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00DD = get_flag(0x00DD) -- Finances topic
    local npc_id = -77 -- Candice's NPC ID

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
        if flag_00DD then
            add_answer( "finances")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00CE then
            add_dialogue("You see a sharply dressed woman with a Fellowship medallion, reviewing a ledger with keen focus.")
            set_flag(0x00CE, true)
        else
            add_dialogue("\"Welcome, \" .. get_player_name() .. \",\" Candice says, her voice steady and professional.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Candice closes her ledger. \"How may I assist thee on behalf of the Fellowship?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Candice, treasurer for the Fellowship, managing our resources under Batlin’s guidance.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I oversee the Fellowship’s finances, ensuring our work thrives with Batlin, Elizabeth, Abraham, Ellen, and Klog. Our stability counters disruptions like Brownie’s campaign.\"")
                add_answer( "finances")
                add_answer( "Batlin")
                add_answer( "Brownie")
                add_answer( "Fellowship")
                set_flag(0x00DD, true)
            elseif choice == "finances" then
                add_dialogue("\"Our funds support Britannia’s unity, aiding allies like Patterson and offering aid to those like Weston, had he sought our help instead of theft.\"")
                add_answer( "Weston")
                add_answer( "Patterson")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("finances")
            elseif choice == "Batlin" then
                add_dialogue("\"Batlin’s vision fuels our mission. With Elizabeth, Abraham, Ellen, and Klog, we secure Britannia’s future, despite rabble-rousers like Brownie.\"")
                add_answer( "Brownie")
                remove_answer("Batlin")
            elseif choice == "Brownie" then
                add_dialogue("\"Brownie’s mayoral bid undermines Britain’s progress. The Fellowship, with Patterson’s support, ensures financial and social order.\"")
                add_answer( "Patterson")
                remove_answer("Brownie")
            elseif choice == "Patterson" then
                add_dialogue("\"Mayor Patterson’s contributions bolster our resources. His leadership aligns with our goals, fostering stability over Brownie’s discord.\"")
                remove_answer("Patterson")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s crime was a tragedy, but Figg’s justice, guided by our principles, was just. Our aid could have spared him such a fate.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s diligence, as seen in Weston’s case, upholds our commitment to Britannia’s prosperity. His loyalty is invaluable.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship unites Britannia, our resources fueling a shared vision. Join us, and contribute to a harmonious future, as many have.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thy willingness is inspiring. Meet Batlin or Elizabeth to join our cause.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Doubt is a step to understanding. Visit our hall, and our work will show thee the truth.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Choose the path of unity, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0458