--- Best guess: Makes an NPC randomly say a context-specific phrase based on their state (e.g., working, eating, playing tag), tailored to human NPCs.
function utility_unknown_1070(P0)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = get_npc_name(P0)
    if not utility_unknown_1079(var_0000) then
        return
    end
    var_0001 = get_schedule_type(var_0000)
    var_0002 = ""
    var_0003 = random2(4, 1)
    if var_0001 == 11 then
        if var_0003 == 1 then
            var_0002 = "@Looks like rain...@"
        elseif var_0003 == 2 then
            var_0002 = "@Greetings.@"
        elseif var_0003 == 3 then
            var_0002 = "@Oh, my aching back...@"
        elseif var_0003 == 4 then
            var_0002 = "@Ho hum...@"
        end
    elseif var_0001 == 14 then
        var_0002 = "@Z-z-z-z...@"
    elseif var_0001 == 23 then
        if var_0003 == 1 then
            var_0002 = "@Try the wine.@"
        elseif var_0003 == 2 then
            var_0002 = "@The bread is fresh.@"
        elseif var_0003 == 3 then
            var_0002 = "@Try the mutton.@"
        elseif var_0003 == 4 then
            var_0002 = "@I recommend the ale.@"
        end
    elseif var_0001 == 28 then
        if var_0003 == 1 then
            var_0002 = "@Strive For Unity.@"
        elseif var_0003 == 2 then
            var_0002 = "@Trust Thy Brother.@"
        elseif var_0003 == 3 then
            var_0002 = "@Worthiness Precedes Reward.@"
        elseif var_0003 == 4 then
            var_0002 = "@Join The Fellowship!@"
        end
    elseif var_0001 == 26 then
        if var_0003 == 1 then
            var_0002 = "@Mmmm! Good!@"
        elseif var_0003 == 2 then
            var_0002 = "@Tasty!@"
        elseif var_0003 == 3 then
            var_0002 = "@This is good!@"
        elseif var_0003 == 4 then
            var_0002 = "@Waiter! Waiter!@"
        end
    elseif var_0001 == 6 then
        if var_0003 == 1 then
            var_0002 = "@Whew! 'Tis hot!@"
        elseif var_0003 == 2 then
            var_0002 = "@Ouch! Cut myself!@"
        elseif var_0003 == 3 then
            var_0002 = "@Work...work...work...@"
        elseif var_0003 == 4 then
            var_0002 = "@We need rain...@"
        end
    elseif var_0001 == 25 then
        if var_0003 == 1 then
            var_0002 = "@Tag! Thou art it!@"
        elseif var_0003 == 2 then
            var_0002 = "@Cannot catch me!@"
        elseif var_0003 == 3 then
            var_0002 = "@Nyah nyah! Thou art it!@"
        elseif var_0003 == 4 then
            var_0002 = "@Catch me if thou can!@"
        end
    end
    bark(P0, var_0002)
end