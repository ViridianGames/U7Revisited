-- Manages Max's dialogue in Britain, covering toddler play, singing, and pacifier interactions in the Royal Nursery.
function func_0420(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        switch_talk_to(-32, 0)
        local0 = get_item_type(-34)

        add_answer({"bye", "job", "name"})

        if not get_flag(161) then
            say("This toddler is full of energy and is playing hard when he sees you. He stops what he is doing.")
            set_flag(161, true)
        end
        say("\"Hi!\" Max grins at you.")

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"Makth.\"")
                if local0 then
                    switch_talk_to(-34, 0)
                    say("\"He says his name is Max.\"")
                    hide_npc(-34)
                    switch_talk_to(-32, 0)
                end
                remove_answer("name")
            elseif answer == "job" then
                local1 = check_item_state(-32)
                if local1 == 25 then
                    say("\"Playing tag!\"")
                    say("The boy runs away from you to catch another child.*")
                    return
                else
                    say("\"I'm a funny boy!\" Max laughs hysterically. \"Makth sing too!\"")
                    add_answer({"sing", "funny boy"})
                end
            elseif answer == "funny boy" then
                say("\"Thou funny boy, -too-!\" Max laughs madly as he throws his pacifier at you. He points at it and says, \"Binky!\"")
                add_answer("Binky")
                remove_answer("funny boy")
            elseif answer == "Binky" then
                say("Max nods furiously. \"Binky! Get Binky! Get Binky!\"")
                say("You realize that the boy wants you to pick it up. Apparently it is some kind of game that only toddlers understand. You pick it up and hand it to him. He immediately plugs it into his mouth.")
                remove_answer("Binky")
            elseif answer == "sing" then
                say("Max stands upright and bellows, \"Old Lord British had a farm, -e-i-e-i-o-! On this farm he had a drake, -e-i-e-i-o-! With a -roar- -roar- here, a -roar- -roar- there, here a -roar-, there a -roar-, everywhere a -roar- -roar-!    Old Lord British had a farm, -e-i-e-i-o-!\"")
                remove_answer("sing")
            elseif answer == "bye" then
                say("\"Bye bye!\"*")
                break
            end
        end
    elseif eventid == 0 then
        local1 = switch_talk_to(-32)
        local2 = check_item_state(-32)
        if local2 == 25 then
            local3 = random(1, 4)
            if local3 == 1 then
                local2 = "@Tag! Thou art it!@"
            elseif local3 == 2 then
                local2 = "@Cannot catch me!@"
            elseif local3 == 3 then
                local2 = "@Nyah nyah! Thou art it!@"
            elseif local3 == 4 then
                local2 = "@Catch me if thou can!@"
            end
            item_say(local2, -32)
        end
    end
    return
end