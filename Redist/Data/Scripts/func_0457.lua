-- func_0457.lua
-- Klog's dialogue as a Fellowship organizer in Britain


function func_0457(eventid)
    local answers = {}
    local flag_00CD = get_flag(0x00CD) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00DC = get_flag(0x00DC) -- Operations topic
    local npc_id = -76 -- Klog's NPC ID

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
        if flag_00DC then
            add_answer( "operations")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00CD then
            add_dialogue("You see a meticulous man with a Fellowship medallion, organizing scrolls with precise care.")
            set_flag(0x00CD, true)
        else
            add_dialogue("\"Greetings, \" .. get_player_name() .. \",\" Klog says, his tone calm and assured.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Klog glances up from his scrolls. \"How may the Fellowship assist thee?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Klog, organizer for the Fellowship, ensuring our work runs smoothly under Batlin’s vision.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I manage the Fellowship’s operations in Britain, coordinating with Batlin, Elizabeth, Abraham, and Ellen. Our efforts unite the city, despite agitators like Brownie.\"")
                add_answer( "operations")
                add_answer( "Batlin")
                add_answer( "Brownie")
                add_answer( "Fellowship")
                set_flag(0x00DC, true)
            elseif choice == "operations" then
                add_dialogue("\"Our operations strengthen Britannia’s communities, supporting leaders like Patterson and guiding souls like Weston, had he chosen us over crime.\"")
                add_answer( "Weston")
                add_answer( "Patterson")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("operations")
            elseif choice == "Batlin" then
                add_dialogue("\"Batlin’s leadership is our cornerstone. With Elizabeth, Abraham, and Ellen, we execute his plan, countering discord from folk like Brownie.\"")
                add_answer( "Brownie")
                remove_answer("Batlin")
            elseif choice == "Brownie" then
                add_dialogue("\"Brownie’s reckless campaign threatens Britain’s stability. The Fellowship, with Patterson’s backing, offers a unified path forward.\"")
                add_answer( "Patterson")
                remove_answer("Brownie")
            elseif choice == "Patterson" then
                add_dialogue("\"Mayor Patterson’s partnership ensures our operations flourish. His vision aligns with ours, fostering order over Brownie’s chaos.\"")
                remove_answer("Patterson")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s theft was a failure of choice. Figg’s justice, rooted in our values, was necessary, but the Fellowship could have offered him salvation.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s resolve, as shown in Weston’s case, reflects our commitment to Britannia’s order. His loyalty strengthens our cause.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship is Britannia’s guiding light, uniting all under our shared purpose. Join us, and find thy place, as many in Britain have done.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thy interest is heartening. Speak with Batlin or Elizabeth to join our ranks.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Uncertainty is a step toward clarity. Visit our hall, and our community will show thee our truth.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Choose unity, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0457