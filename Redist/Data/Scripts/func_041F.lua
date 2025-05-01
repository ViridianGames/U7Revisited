-- Function 041F: Manages Kristy's dialogue and interactions
function func_041F(itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid() == 1 then
        switch_talk_to(31, 0)
        local0 = call_08F7H(-34)
        add_answer({"bye", "job", "name"})
        if not get_flag(160) then
            add_dialogue("This is a cute toddler holding a baby doll.")
            add_dialogue("\"Hi!\" Kristy exclaims.")
            set_flag(160, true)
        else
            add_dialogue("\"Hi!\" Kristy exclaims.")
        end
        while true do
            if cmp_strings("name", 1) then
                add_dialogue("\"Kwisty.\"")
                if local0 then
                    switch_talk_to(34, 0)
                    add_dialogue("\"Kristy, like Nicholas, is one of our orphans. She was found in an abandoned home in Paws by one of the Great Council members.\"")
                    _HideNPC(-34)
                    switch_talk_to(31, 0)
                end
                remove_answer("name")
            elseif cmp_strings("job", 1) then
                local1 = callis_001C(-31)
                if local1 == 25 then
                    add_dialogue("\"Tag! Playing tag!\"")
                    add_dialogue("The toddler runs off in search of a nursery-mate.*")
                    abort()
                else
                    add_dialogue("Kristy looks confused. \"Sing. Horsey. Rosa. Winner.\"")
                    add_answer({"winner", "Rosa", "horsey", "sing"})
                end
            elseif cmp_strings("sing", 1) then
                add_dialogue("Kristy is more than happy to do so. \"A-B-C-D-E-F-G! H-I-K-M-M-M-O-P! Q-T-W-Y-X-Z!\" She is proud of her song, although she didn't get it quite right.")
                remove_answer("sing")
            elseif cmp_strings("horsey", 1) then
                add_dialogue("\"I love horsey!\" She rocks hard on the rocking horse.")
                remove_answer("horsey")
            elseif cmp_strings("Rosa", 1) then
                add_dialogue("Kristy hugs her baby doll tight. \"Rosa!\"")
                remove_answer("Rosa")
            elseif cmp_strings("winner", 1) then
                add_dialogue("\"I am winner!\" she proclaims loudly.")
                if local0 then
                    switch_talk_to(34, 0)
                    add_dialogue("\"She keeps saying that. I am not sure what it means. Something to do with a competition.\"")
                    _HideNPC(-34)
                    switch_talk_to(31, 0)
                end
                remove_answer("winner")
            elseif cmp_strings("bye", 1) then
                add_dialogue("\"Bye bye!\"*")
                break
            end
        end
    elseif eventid() == 0 then
        local1 = callis_001B(-31)
        local2 = callis_001C(local1)
        if local2 == 25 then
            local3 = callis_0010(4, 1)
            if local3 == 1 then
                local0 = "@Tag! Thou art it!@"
            elseif local3 == 2 then
                local0 = "@Cannot catch me!@"
            elseif local3 == 3 then
                local0 = "@Nyah nyah! Thou art it!@"
            elseif local3 == 4 then
                local0 = "@Catch me if thou can!@"
            end
            bark(31, local0)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function add_dialogue(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function cmp_strings(str, count)
    return false -- Placeholder
end

function abort()
    -- Placeholder
end