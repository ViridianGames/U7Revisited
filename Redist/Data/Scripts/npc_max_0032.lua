--- Best guess: Handles dialogue with Max, a toddler in the Royal Nursery, engaging in playful interactions like tag, singing, and a pacifier game.
function npc_max_0032(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if eventid == 1 then
        switch_talk_to(32)
        add_answer({"bye", "job", "name"})
        if not get_flag(161) then
            add_dialogue("This toddler is full of energy and is playing hard when he sees you. He stops what he is doing.")
            set_flag(161, true)
        else
            add_dialogue("\"Hi!\" Max grins at you.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"Makth.\"")
                var_0000 = npc_id_in_party(34) --- Guess: Checks player status
                if var_0000 then
                    switch_talk_to(34)
                    add_dialogue("\"He says his name is Max.\"")
                    hide_npc(34)
                    switch_talk_to(32)
                end
                remove_answer("name")
            elseif var_0000 == "job" then
                var_0001 = get_schedule_type(32) --- Guess: Gets object state
                if var_0001 == 25 then
                    add_dialogue("\"Playing tag!\"")
                    add_dialogue("The boy runs away from you to catch another child.")
                    abort()
                else
                    add_dialogue("\"I'm a funny boy!\" Max laughs hysterically. \"Makth sing too!\"")
                    add_answer({"sing", "funny boy"})
                end
            elseif var_0000 == "funny boy" then
                add_dialogue("\"Thou funny boy, -too-!\" Max laughs madly as he throws his pacifier at you. He points at it and says, \"Binky!\"")
                add_answer("Binky")
                remove_answer("funny boy")
            elseif var_0000 == "Binky" then
                add_dialogue("Max nods furiously. \"Binky! Get Binky! Get Binky!\"")
                add_dialogue("You realize that the boy wants you to pick it up. Apparently it is some kind of game that only toddlers understand. You pick it up and hand it to him. He immediately plugs it into his mouth.")
                remove_answer("Binky")
            elseif var_0000 == "sing" then
                add_dialogue("Max stands upright and bellows, \"Old Lord British had a farm, -e-i-e-i-o-! On this farm he had a drake, -e-i-e-i-o-! With a -roar- -roar- here, a -roar- -roar- there, here a -roar-, there a -roar-, everywhere a -roar- -roar-!    Old Lord British had a farm, -e-i-e-i-o-!\"")
                remove_answer("sing")
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("\"Bye bye!\"")
    elseif eventid == 0 then
        var_0001 = get_schedule_type(32) --- Guess: Gets object state
        if var_0001 == 25 then
            var_0002 = random(1, 4)
            if var_0002 == 1 then
                var_0003 = "@Tag! Thou art it!@"
            elseif var_0002 == 2 then
                var_0003 = "@Cannot catch me!@"
            elseif var_0002 == 3 then
                var_0003 = "@Nyah nyah! Thou art it!@"
            elseif var_0002 == 4 then
                var_0003 = "@Catch me if thou can!@"
            end
            bark(32, var_0003)
        end
    end
end