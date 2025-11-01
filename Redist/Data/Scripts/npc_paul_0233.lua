--- Best guess: Manages Paul's dialogue in Buccaneer's Den, an actor organizing the Passion Play performance about The Fellowship, handling ticket sales and scheduling.
function npc_paul_0233(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0009, var_000A, var_000B, var_000C

    if eventid == 1 then
        switch_talk_to(0, 233)
        var_0000 = get_schedule_type(get_npc_name(233))
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(696) then
            add_dialogue("You see a young entertainer who beckons to you.")
            set_flag(696, true)
        else
            add_dialogue("\"Yes?\" Paul asks.")
        end
        while true do
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
                    break
                end
                add_dialogue("\"Wouldst thou like to see our Passion Play?\"")
                if ask_yes_no() then
                    var_0001 = npc_id_in_party(234)
                    var_0002 = npc_id_in_party(235)
                    if var_0001 and var_0002 then
                        var_0003 = get_party_members()
                        var_0004 = 0
                        var_0005 = get_party_gold()
                        for _ = 1, var_0003 do
                            var_0004 = var_0004 + 1
                        end
                        if var_0005 >= var_0004 * 2 then
                            var_0009 = remove_party_items(true, 359, 359, 644, var_0004)
                            add_dialogue("Paul takes your gold. \"We thank thee. If thou wouldst make thyself comfortable, we shall begin.\"")
                            utility_ship_0967()
                        else
                            add_dialogue("\"Oh dear. I am afraid thou dost not have enough gold to pay for the performance. Some other time, I hope.\"")
                            return
                        end
                    else
                        add_dialogue("\"I am sorry. It seems my fellow thespians are not available. The Passion Play has temporarily closed.\"")
                        return
                    end
                else
                    add_dialogue("\"Some other time, then, I hope.\"")
                    return
                end
            elseif answer == "bye" then
                add_dialogue("The actor bows to you.")
                break
            end
        end
    elseif eventid == 0 then
        var_000A = get_schedule()
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
            utility_unknown_1070(233)
        end
    end
    return
end