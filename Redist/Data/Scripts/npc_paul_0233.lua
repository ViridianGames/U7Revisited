--- Best guess: Manages Paul's dialogue — actor organizing the Passion Play about The Fellowship
--- (ticket sales + scheduling). Conversation loop matches npc_gargan_0021.lua.
function npc_paul_0233(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0009, var_000A, var_000B, var_000C

    --- True if the actor exists (and, when possible, is near the Avatar).
    --- Note: original decompile used npc_id_in_party(234/235), which is wrong —
    --- Meryl/Dustin are never party members.
    local function actor_ready(npc_id)
        local npc = get_npc_name(npc_id)
        if not npc then
            return false
        end
        local ok, sched = pcall(get_schedule_type, npc)
        if ok and sched ~= nil and sched ~= 29 then
            return false
        end
        if get_npc_object_id and is_near_object then
            local obj_id = get_npc_object_id(npc_id)
            if obj_id and obj_id >= 0 then
                return is_near_object(0, obj_id, 24)
            end
        end
        return true
    end

    start_conversation()
    if eventid == 1 then
        switch_talk_to(233)
        var_0000 = get_schedule_type(get_npc_name(233))
        add_answer({"bye", "job", "name"})
        if not get_flag(696) then
            add_dialogue("You see a young entertainer who beckons to you.")
            set_flag(696, true)
        else
            add_dialogue("\"Yes?\" Paul asks.")
        end
        while true do
            coroutine.yield()
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Paul. My colleagues' names are Meryl and Dustin.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"We perform a Passion Play about The Fellowship. It costs only 2 gold per person to see. If thou dost want us to perform it, please say so.\"")
                add_answer({"perform", "Fellowship", "Passion Play"})
            elseif answer == "Passion Play" then
                add_dialogue("\"A Passion Play is a morality tale performed on stage.\"")
                remove_answer("Passion Play")
            elseif answer == "Fellowship" then
                add_dialogue("\"It would be much simpler to view the play.\"")
                remove_answer("Fellowship")
            elseif answer == "perform" then
                if var_0000 ~= 29 then
                    add_dialogue("\"I am sorry to say we are on our break. Please return to the stage area during normal hours.\"")
                    remove_answer("perform")
                else
                    add_dialogue("\"Wouldst thou like to see our Passion Play?\"")
                    if ask_yes_no() then
                        var_0001 = actor_ready(234) -- Meryl
                        var_0002 = actor_ready(235) -- Dustin
                        if var_0001 and var_0002 then
                            var_0003 = get_party_members() or {}
                            var_0004 = #var_0003
                            if var_0004 < 1 then
                                var_0004 = 1
                            end
                            local cost = var_0004 * 2
                            var_0005 = get_party_gold()
                            if var_0005 >= cost then
                                var_0009 = remove_party_items(true, 359, 359, 644, cost)
                                add_dialogue("Paul takes your gold. \"We thank thee. If thou wouldst make thyself comfortable, we shall begin.\"")
                                clear_answers()
                                -- Play queues into this conversation; then we exit the answer loop.
                                utility_ship_0967()
                                return
                            else
                                add_dialogue("\"Oh dear. I am afraid thou dost not have enough gold to pay for the performance. Some other time, I hope.\"")
                                remove_answer("perform")
                            end
                        else
                            add_dialogue("\"I am sorry. It seems my fellow thespians are not available. The Passion Play has temporarily closed.\"")
                            remove_answer("perform")
                        end
                    else
                        add_dialogue("\"Some other time, then, I hope.\"")
                        remove_answer("perform")
                    end
                end
            elseif answer == "bye" then
                add_dialogue("The actor bows to you.")
                clear_answers()
            end
        end
    elseif eventid == 0 then
        var_000A = get_schedule(233)
        var_0000 = get_schedule_type(get_npc_name(233))
        if var_0000 == 29 then
            var_000B = random2(4, 1)
            if var_000B == 1 then
                var_000C = "@See the Passion Play!@"
            elseif var_000B == 2 then
                var_000C = "@The Fellowship presents...@"
            elseif var_000B == 3 then
                var_000C = "@Come view the Passion Play!@"
            elseif var_000B == 4 then
                var_000C = "@We shall entertain thee!@"
            end
            bark(233, var_000C)
        else
            utility_npc_random_bark_1070(233)
        end
    end
end
