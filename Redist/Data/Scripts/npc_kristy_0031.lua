--- Best guess: Manages Kristy's dialogue, a toddler at an orphanage discussing her games and toys, with flag-based interactions involving another NPC.
function npc_kristy_0031(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid ~= 1 then
        if eventid == 0 then
            var_0001 = get_schedule_type(get_npc_name(-31))
            if var_0001 == 25 then
                var_0002 = random2(4, 1)
                if var_0002 == 1 then
                    var_0003 = "@Tag! Thou art it!@"
                elseif var_0002 == 2 then
                    var_0003 = "@Cannot catch me!@"
                elseif var_0003 == 3 then
                    var_0003 = "@Nyah nyah! Thou art it!@"
                elseif var_0004 == 4 then
                    var_0003 = "@Catch me if thou can!@"
                end
                bark(var_0003, -31)
            end
        end
        add_dialogue("\"Bye bye!\"")
        return
    end

    start_conversation()
    switch_talk_to(0, -31)
    var_0000 = npc_id_in_party(-34)
    add_answer({"bye", "job", "name"})
    if not get_flag(160) then
        add_dialogue("This is a cute toddler holding a baby doll.")
        set_flag(160, true)
    else
        add_dialogue("\"Hi!\" Kristy exclaims.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"Kwisty.\"")
            if var_0000 then
                switch_talk_to(0, -34)
                add_dialogue("\"Kristy, like Nicholas, is one of our orphans. She was found in an abandoned home in Paws by one of the Great Council members.\"")
                --syntax error hide_npc34)
                switch_talk_to(0, -31)
            end
            remove_answer("name")
        elseif cmps("job") then
            var_0001 = get_schedule_type(-31)
            if var_0001 == 25 then
                add_dialogue("\"Tag! Playing tag!\"")
                add_dialogue("The toddler runs off in search of a nursery-mate.")
                return
            else
                add_dialogue("Kristy looks confused. \"Sing. Horsey. Rosa. Winner.\"")
                add_answer({"winner", "Rosa", "horsey", "sing"})
            end
        elseif cmps("sing") then
            add_dialogue("Kristy is more than happy to do so. \"A-B-C-D-E-F-G! H-I-K-M-M-M-O-P! Q-T-W-Y-X-Z!\" She is proud of her song, although she didn't get it quite right.")
            remove_answer("sing")
        elseif cmps("horsey") then
            add_dialogue("\"I love horsey!\" She rocks hard on the rocking horse.")
            remove_answer("horsey")
        elseif cmps("Rosa") then
            add_dialogue("Kristy hugs her baby doll tight. \"Rosa!\"")
            remove_answer("Rosa")
        elseif cmps("winner") then
            add_dialogue("\"I am winner!\" she proclaims loudly.")
            if var_0000 then
                switch_talk_to(0, -34)
                add_dialogue("\"She keeps saying that. I am not sure what it means. Something to do with a competition.\"")
                --syntax error hide_npc34)
                switch_talk_to(0, -31)
            end
            remove_answer("winner")
        elseif cmps("bye") then
            break
        end
    end
    return
end