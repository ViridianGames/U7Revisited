require "U7LuaFuncs"
-- Displays random NPC dialogue with a "To" prefix based on NPC state.
function func_092F(p0)
    local local1, local2, local3, local4

    local1 = external_001BH(p0) -- Unmapped intrinsic
    if not external_0937H(local1) then -- Unmapped intrinsic
        return
    end
    local2 = external_001CH(local1) -- Unmapped intrinsic
    local3 = ""
    local4 = get_random(1, 4)
    if local2 == 11 then
        if local4 == 1 then
            local3 = "@To say hello!@"
        elseif local4 == 2 then
            local3 = "@To greet you!@"
        elseif local4 == 3 then
            local3 = "@To hope you have a nice day!@"
        elseif local4 == 4 then
            local3 = "@To ask how you are?@"
        end
    elseif local2 == 14 then
        local3 = "@Z-z-z-z...@"
    elseif local2 == 23 then
        if local4 == 1 then
            local3 = "@To suggest you try the wine.@"
        elseif local4 == 2 then
            local3 = "@To offer fresh food.@"
        elseif local4 == 3 then
            local3 = "@To recommend the mutton.@"
        elseif local4 == 4 then
            local3 = "@To recommend the ale.@"
        end
    elseif local2 == 28 then
        if local4 == 1 then
            local3 = "@To Strive For Unity.@"
        elseif local4 == 2 then
            local3 = "@To Trust Thy Brother.@"
        elseif local4 == 3 then
            local3 = "@To say Worthiness Precedes Reward.@"
        elseif local4 == 4 then
            local3 = "@To join The Fellowship!@"
        end
    elseif local2 == 26 then
        if local4 == 1 then
            local3 = "@To be very Good!@"
        elseif local4 == 2 then
            local3 = "@To be tasty!@"
        elseif local4 == 3 then
            local3 = "@To be delicious!@"
        elseif local4 == 4 then
            local3 = "@To call for service!@"
        end
    end
    item_say(local3, local1)
    return
end