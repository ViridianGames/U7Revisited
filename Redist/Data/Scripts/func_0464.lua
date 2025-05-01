-- func_0464.lua
-- Dell's dialogue as a shopkeeper in Britain


function func_0464(eventid)
    local answers = {}
    local flag_00D4 = get_flag(0x00D4) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00E3 = get_flag(0x00E3) -- Shop topic
    local npc_id = -83 -- Dell's NPC ID

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
        if flag_00E3 then
            add_answer( "shop")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00D4 then
            add_dialogue("You see a busy man arranging goods in a bustling shop, his apron dusted with flour.")
            set_flag(0x00D4, true)
        else
            add_dialogue("\"Hail, \" .. get_player_name() .. \",\" Dell says, wiping his hands.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Dell grins. \"Need supplies or just a chat?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Dell, shopkeeper of Britain, sellin’ all thou might need.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I run this shop, sellin’ food, tools, and more. The Fellowship’s trade rules help stock my shelves, but their sway over Patterson’s a bit much.\"")
                add_answer( "shop")
                add_answer( "Fellowship")
                set_flag(0x00E3, true)
            elseif choice == "shop" then
                add_dialogue("\"Got bread, tools, even some cloth. Prices are high, though—folk like Weston can’t afford much, and that leads to trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("shop")
            elseif choice == "prices" then
                add_dialogue("\"Taxes and Fellowship fees drive costs up. It’s tough on the poor, like those in Paws, pushin’ ‘em to desperate acts.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of here. Many, like Weston, barely scrape by, and the Fellowship’s promises don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—heartbreakin’. Figg’s quick arrest, with Fellowship backin’, showed no compassion.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s all for the Fellowship, enforcin’ their rules. His part in Weston’s arrest makes me doubt their talk of unity.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s trade deals keep goods flowin’, but their hold on Patterson and folk like Figg makes me think they’re after more than unity.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou believest their cause? They aid trade, but I keep an eye on ‘em.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to question ‘em. Their influence feels heavier than their promises.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Take care, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0464