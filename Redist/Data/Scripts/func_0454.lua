-- func_0454.lua
-- Elizabeth's dialogue as a Fellowship member in Britain


function func_0454(eventid)
    local answers = {}
    local flag_00CA = get_flag(0x00CA) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00D9 = get_flag(0x00D9) -- Outreach topic
    local npc_id = -73 -- Elizabeth's NPC ID

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
        if flag_00D9 then
            add_answer( "outreach")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00CA then
            add_dialogue("You see a poised woman with a welcoming smile, her Fellowship medallion gleaming.")
            set_flag(0x00CA, true)
        else
            add_dialogue("\"Greetings, \" .. get_player_name() .. \",\" Elizabeth says, her tone inviting.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Elizabeth gestures warmly. \"How may I guide thee today?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"I am Elizabeth, a devoted servant of the Fellowship, here to foster unity.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I oversee the Fellowship’s outreach in Britain, helping all embrace our path. Leaders like Patterson and loyal members like Figg aid our cause.\"")
                add_answer( "outreach")
                add_answer( "Patterson")
                add_answer( "Figg")
                add_answer( "Fellowship")
                set_flag(0x00D9, true)
            elseif choice == "outreach" then
                add_dialogue("\"We reach out to all, from nobles to farmers, offering purpose. Even those like Weston could find redemption through our teachings.\"")
                add_answer( "Weston")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("outreach")
            elseif choice == "Patterson" then
                add_dialogue("\"Mayor Patterson understands our vision for a united Britain. His support ensures our message spreads, unlike Brownie’s divisive campaign.\"")
                add_answer( "Brownie")
                remove_answer("Patterson")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s dedication to order, as seen in Weston’s case, reflects our values. He protects Britannia’s prosperity with unwavering loyalty.\"")
                add_answer( "Weston")
                remove_answer("Figg")
            elseif choice == "Brownie" then
                add_dialogue("\"Brownie’s challenge to Patterson sows discord. The Fellowship promotes harmony, guiding Britain toward a brighter future.\"")
                remove_answer("Brownie")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s crime was unfortunate, but justice, as upheld by Figg, strengthens us. The Fellowship could have offered him a better path, had he sought it.\"")
                remove_answer("Weston")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship is Britannia’s hope, uniting all under Batlin’s vision. Join us, and thou wilt find purpose, as many in Britain have.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thy openness warms my heart. Speak with Batlin to join our family.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Skepticism is understandable. Visit our hall, meet our members, and see our truth.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Embrace unity, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0454