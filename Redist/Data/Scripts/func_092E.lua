require "U7LuaFuncs"
-- Displays random NPC dialogue based on NPC state.
function func_092E(p0)
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
            local3 = "@Looks like rain...@"
        elseif local4 == 2 then
            local3 = "@Greetings.@"
        elseif local4 == 3 then
            local3 = "@Oh, my aching back...@"
        elseif local4 == 4 then
            local3 = "@Ho hum...@"
        end
    elseif local2 == 14 then
        local3 = "@Z-z-z-z...@"
    elseif local2 == 23 then
        if local4 == 1 then
            local3 = "@Try the wine.@"
        elseif local4 == 2 then
            local3 = "@The bread is fresh.@"
        elseif local4 == 3 then
            local3 = "@Try the mutton.@"
        elseif local4 == 4 then
            local3 = "@I recommend the ale.@"
        end
    elseif local2 == 28 then
        if local4 == 1 then
            local3 = "@Strive For Unity.@"
        elseif local4 == 2 then
            local3 = "@Trust Thy Brother.@"
        elseif local4 == 3 then
            local3 = "@Worthiness Precedes Reward.@"
        elseif local4 == 4 then
            local3 = "@Join The Fellowship!@"
        end
    elseif local2 == 26 then
        if local4 == 1 then
            local3 = "@Mmmm! Good!@"
        elseif local4 == 2 then
            local3 = "@Tasty!@"
        elseif local4 == 3 then
            local3 = "@This is good!@"
        elseif local4 == 4 then
            local3 = "@Waiter! Waiter!@"
        end
    elseif local2 == 6 then
        if local4 == 1 then
            local3 = "@Whew! 'Tis hot!@"
        elseif local4 == 2 then
            local3 = "@Ouch! Cut myself!@"
        elseif local4 == 3 then
            local3 = "@Work...work...work...@"
        elseif local4 == 4 then
            local3 = "@We need rain...@"
        end
    elseif local2 == 25 then
        if local4 == 1 then
            local3 = "@Tag! Thou art it!@"
        elseif local4 == 2 then
            local3 = "@Cannot catch me!@"
        elseif local4 == 3 then
            local3 = "@Nyah nyah! Thou art it!@"
        elseif local4 == 4 then
            local3 = "@Catch me if thou can!@"
        end
    end
    item_say(local3, local1)
    return
end