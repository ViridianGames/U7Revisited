-- func_0456.lua
-- Ellen's dialogue as a Fellowship recruiter in Britain


function func_0456(eventid)
    local answers = {}
    local flag_00CC = get_flag(0x00CC) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00DB = get_flag(0x00DB) -- Community topic
    local npc_id = -75 -- Ellen's NPC ID

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
        if flag_00DB then
            add_answer( "community")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00CC then
            add_dialogue("You see a cheerful woman with a Fellowship medallion, distributing pamphlets with a warm smile.")
            set_flag(0x00CC, true)
        else
            add_dialogue("\"Hello again, \" .. get_player_name() .. \",\" Ellen says, offering a pamphlet.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Ellen beams. \"What can the Fellowship share with thee today?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"I’m Ellen, a recruiter for the Fellowship, here to bring Britannia together.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I recruit for the Fellowship, building our community with Batlin, Elizabeth, and Abraham. We help all, unlike troublemakers like Brownie.\"")
                add_answer( "community")
                add_answer( "Batlin")
                add_answer( "Brownie")
                add_answer( "Fellowship")
                set_flag(0x00DB, true)
            elseif choice == "community" then
                add_dialogue("\"Our community uplifts Britannia, from leaders like Patterson to workers. Even those like Weston could find solace with us, had he joined.\"")
                add_answer( "Weston")
                add_answer( "Patterson")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("community")
            elseif choice == "Batlin" then
                add_dialogue("\"Batlin’s wisdom guides us. With Elizabeth and Abraham, we spread his vision, countering divisive voices like Brownie’s.\"")
                add_answer( "Brownie")
                remove_answer("Batlin")
            elseif choice == "Brownie" then
                add_dialogue("\"Brownie’s campaign stirs unrest, challenging Patterson’s leadership. The Fellowship offers unity, a path he cannot provide.\"")
                add_answer( "Patterson")
                remove_answer("Brownie")
            elseif choice == "Patterson" then
                add_dialogue("\"Mayor Patterson’s alliance with us strengthens Britain. His support ensures our community thrives, unlike Brownie’s chaos.\"")
                remove_answer("Patterson")
            elseif choice == "Weston" then
                add_dialogue("\"Weston’s theft was sad, but Figg’s justice, guided by our principles, was necessary. The Fellowship could have given him purpose.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s loyalty, seen in handling Weston’s case, exemplifies our dedication to order. He’s a true Fellowship member.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship unites Britannia, offering hope to all. Join us, as many have, and discover thy role in our harmonious future.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thy eagerness gladdens me. Speak with Batlin or Elizabeth to join our cause.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Doubt is but a step to truth. Visit our hall, and let our community show thee the way.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Find thy place with us, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0456