-- Function 041F: Manages Kristy's dialogue and interactions
function func_041F(itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid() == 1 then
        switch_talk_to(31, 0)
        local0 = call_08F7H(-34)
        _AddAnswer({"bye", "job", "name"})
        if not get_flag(160) then
            say("This is a cute toddler holding a baby doll.")
            say("\"Hi!\" Kristy exclaims.")
            set_flag(160, true)
        else
            say("\"Hi!\" Kristy exclaims.")
        end
        while true do
            if cmp_strings("name", 1) then
                say("\"Kwisty.\"")
                if local0 then
                    switch_talk_to(34, 0)
                    say("\"Kristy, like Nicholas, is one of our orphans. She was found in an abandoned home in Paws by one of the Great Council members.\"")
                    _HideNPC(-34)
                    switch_talk_to(31, 0)
                end
                _RemoveAnswer("name")
            elseif cmp_strings("job", 1) then
                local1 = callis_001C(-31)
                if local1 == 25 then
                    say("\"Tag! Playing tag!\"")
                    say("The toddler runs off in search of a nursery-mate.*")
                    abort()
                else
                    say("Kristy looks confused. \"Sing. Horsey. Rosa. Winner.\"")
                    _AddAnswer({"winner", "Rosa", "horsey", "sing"})
                end
            elseif cmp_strings("sing", 1) then
                say("Kristy is more than happy to do so. \"A-B-C-D-E-F-G! H-I-K-M-M-M-O-P! Q-T-W-Y-X-Z!\" She is proud of her song, although she didn't get it quite right.")
                _RemoveAnswer("sing")
            elseif cmp_strings("horsey", 1) then
                say("\"I love horsey!\" She rocks hard on the rocking horse.")
                _RemoveAnswer("horsey")
            elseif cmp_strings("Rosa", 1) then
                say("Kristy hugs her baby doll tight. \"Rosa!\"")
                _RemoveAnswer("Rosa")
            elseif cmp_strings("winner", 1) then
                say("\"I am winner!\" she proclaims loudly.")
                if local0 then
                    switch_talk_to(34, 0)
                    say("\"She keeps saying that. I am not sure what it means. Something to do with a competition.\"")
                    _HideNPC(-34)
                    switch_talk_to(31, 0)
                end
                _RemoveAnswer("winner")
            elseif cmp_strings("bye", 1) then
                say("\"Bye bye!\"*")
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
            _ItemSay(local0, -31)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function say(...)
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