--- Best guess: Makes a gargoyle NPC randomly say a context-specific phrase in their syntax (e.g., “To say hello!”), based on their state.
function func_092F(P0)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = get_npc_name(P0)
    if not unknown_0937H(var_0000) then
        return
    end
    var_0001 = unknown_001CH(var_0000)
    var_0002 = ""
    var_0003 = random2(4, 1)
    if var_0001 == 11 then
        if var_0003 == 1 then
            var_0002 = "@To say hello!@"
        elseif var_0003 == 2 then
            var_0002 = "@To greet you!@"
        elseif var_0003 == 3 then
            var_0002 = "@To hope you have a nice day!@"
        elseif var_0003 == 4 then
            var_0002 = "@To ask how you are?@"
        end
    elseif var_0001 == 14 then
        var_0002 = "@Z-z-z-z...@"
    elseif var_0001 == 23 then
        if var_0003 == 1 then
            var_0002 = "@To suggest you try the wine.@"
        elseif var_0003 == 2 then
            var_0002 = "@To offer fresh food.@"
        elseif var_0003 == 3 then
            var_0002 = "@To recommend the mutton.@"
        elseif var_0003 == 4 then
            var_0002 = "@To recommend the ale.@"
        end
    elseif var_0001 == 28 then
        if var_0003 == 1 then
            var_0002 = "@To Strive For Unity.@"
        elseif var_0003 == 2 then
            var_0002 = "@To Trust Thy Brother.@"
        elseif var_0003 == 3 then
            var_0002 = "@To say Worthiness Precedes Reward.@"
        elseif var_0003 == 4 then
            var_0002 = "@To join The Fellowship!@"
        end
    elseif var_0001 == 26 then
        if var_0003 == 1 then
            var_0002 = "@To be very Good!@"
        elseif var_0003 == 2 then
            var_0002 = "@To be tasty!@"
        elseif var_0003 == 3 then
            var_0002 = "@To be delicious!@"
        elseif var_0003 == 4 then
            var_0002 = "@To call for service!@"
        end
    end
    bark(var_0002, var_0000)
end