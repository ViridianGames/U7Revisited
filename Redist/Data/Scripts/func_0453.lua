-- func_0453.lua
-- Batlin's dialogue as the Fellowship leader in Britain


function func_0453(eventid)
    local answers = {}
    local flag_00C9 = get_flag(0x00C9) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00D8 = get_flag(0x00D8) -- Philosophy topic
    local npc_id = -72 -- Batlin's NPC ID

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
        if flag_00D8 then
            add_answer( "philosophy")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00C9 then
            add_dialogue("You see a charismatic man with a serene smile, his robes adorned with the Fellowship’s symbol.")
            set_flag(0x00C9, true)
        else
            add_dialogue("\"Welcome, \" .. get_player_name() .. \",\" Batlin says, his voice warm yet measured.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Batlin clasps his hands. \"How may the Fellowship serve thee?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"I am Batlin, humble leader of the Fellowship, guiding Britannia toward unity.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I lead the Fellowship, spreading our philosophy of unity and trust. We aid Britannia’s people, from mayors like Patterson to the humblest farmer.\"")
                add_answer( "philosophy")
                add_answer( "Patterson")
                add_answer( "Fellowship")
                set_flag(0x00D8, true)
            elseif choice == "philosophy" then
                add_dialogue("\"Our philosophy is simple: strive, trust, and unite. We help all, unlike divisive voices like that farmer Brownie, who sows discord.\"")
                add_answer( "Brownie")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("philosophy")
            elseif choice == "Patterson" then
                add_dialogue("\"Mayor Patterson is a valued ally, embracing our vision for a prosperous Britain. His leadership counters rabble-rousers like Brownie.\"")
                add_answer( "Brownie")
                remove_answer("Patterson")
            elseif choice == "Brownie" then
                add_dialogue("\"Brownie’s campaign is misguided, stirring unrest among the simple folk. The Fellowship supports order, as seen in cases like Weston’s just punishment.\"")
                add_answer( "Weston")
                remove_answer("Brownie")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s theft was a crime, and Figg’s vigilance, guided by our principles, ensured justice. Compassion must not undermine order.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg is a loyal member, protecting Britannia’s resources. His actions, like reporting Weston, reflect our commitment to stability.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship unites Britannia, offering purpose to all. Join us, and thou wilt see our vision for a harmonious land, free of strife.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou art wise to embrace our path. Visit our hall to learn more.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Doubt is natural, but meet our members—like Patterson or Figg—and thou wilt see our truth.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Walk the path of unity, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0453