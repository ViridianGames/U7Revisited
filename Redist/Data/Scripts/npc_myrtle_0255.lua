--- Best guess: Manages Myrtle's (Mama's) dialogue in Bee Cave, living with Murray (Papa), with a secret past revealed by Papa, reacting to the player and Spark's presence.
function npc_myrtle_0255(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 0 then
        return
    end
    switch_talk_to(0, 255)
    var_0000 = npc_id_in_party(241)
    var_0001 = npc_id_in_party(2)
    var_0002 = npc_id_in_party(1)
    var_0003 = npc_id_in_party(4)
    var_0004 = false
    start_conversation()
    add_answer({"bye", "job", "name"})
    if not get_flag(704) then
        add_dialogue("You see a lovely naked woman. She is not in the least concerned that she is wearing no clothes.")
        if var_0001 and var_0002 then
            switch_talk_to(0, 2)
            add_dialogue("Spark's eyes widen and his jaw drops.")
            hide_npc(2)
            switch_talk_to(0, 1)
            add_dialogue("\"Close thy mouth, boy. An insect may fly in. And put thine eyes back in thine head. They shall look strange dangling out of their sockets.\"")
            hide_npc(1)
            switch_talk_to(0, 255)
        end
        add_dialogue("\"Me Mama!\" the woman exclaims proudly.")
        if not get_flag(724) then
            if var_0000 then
                switch_talk_to(0, 241)
                add_dialogue("\"Forget it, Myrtle. The jig is up. They know all about us.\"")
                switch_talk_to(0, 255)
                add_dialogue("\"Murray! Didst thou give us away? How couldst thou do it? This just isn't going to be much fun anymore knowing that someone is aware of the truth!\"")
                switch_talk_to(0, 241)
                add_dialogue("\"Sorry, dear.\"")
                hide_npc(241)
                switch_talk_to(0, 255)
                var_0004 = true
            else
                add_dialogue("You tell the woman what Papa said about their past lives.")
                add_dialogue("\"Well, blast it! Why did he tell our secret? I will never forgive him! What a knave!\"")
                var_0004 = true
            end
        end
        set_flag(704, true)
    else
        add_dialogue("\"Hmm?\" asks Mama.")
        if not get_flag(724) then
            var_0004 = true
        end
    end
    while true do
        local answer = get_answer()
        if answer == "name" then
            if not var_0004 then
                add_dialogue("\"Me Mama!\" the woman exclaims again.")
            else
                add_dialogue("\"All right. My name is Myrtle. But I like to be called Mama.\"")
            end
            remove_answer("name")
        elseif answer == "job" then
            if not var_0004 then
                add_dialogue("\"Me live with Papa here in cave!\"")
            else
                add_dialogue("\"Well, I would not call it a job, but I just live here in Bee Cave with Papa.\"")
            end
            add_answer({"cave", "Papa", "live"})
        elseif answer == "live" then
            if not var_0004 then
                add_dialogue("Mama explains. \"Eat. Sleep. Love.\"")
                if var_0003 then
                    switch_talk_to(0, 4)
                    add_dialogue("\"What else is there?\"")
                    hide_npc(4)
                    switch_talk_to(0, 255)
                end
            else
                add_dialogue("\"We do our best to eat, sleep, and love each other down here isolated from the rest of society.\"")
            end
            remove_answer("live")
        elseif answer == "Papa" then
            if not var_0004 then
                add_dialogue("\"Mmmmmmm. Papa! Mama love Papa!\"")
            else
                add_dialogue("\"He's mostly a lazy beggar, but I still love him.\"")
            end
            remove_answer("Papa")
        elseif answer == "cave" then
            if not var_0004 then
                add_dialogue("\"Cave good. Warm. Safe.\"")
            else
                add_dialogue("\"It's been good to us. It keeps us warm. We are able to find food. I do not miss the old life.\"")
            end
            remove_answer("cave")
        elseif answer == "bye" then
            add_dialogue("\"'Bye!\"")
            break
        end
    end
    return
end