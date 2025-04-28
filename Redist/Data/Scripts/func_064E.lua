require "U7LuaFuncs"
-- Casts the "In Wis" spell, displaying the player's directional coordinates (e.g., "West North").
function func_064E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        item_say("@In Wis@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1614, 8021, 4, 17447, 17519, 17505, 8045, 67, 7768})
        else
            local0 = add_item(itemref, {1542, 17493, 17519, 17505, 7789})
        end
    elseif eventid == 2 then
        local1 = get_item_data(-356)
        local2 = (local1[1] - 933) / 10
        local3 = (local1[2] - 1134) / 10
        if local2 < 0 then
            local4 = " " .. external_0932H(local2) .. " West"
        else
            local4 = " " .. external_0932H(local2) .. " East"
        end
        if local3 < 0 then
            local5 = " " .. external_0932H(local3) .. " North"
        else
            local5 = " " .. external_0932H(local3) .. " South"
        end
        item_say(local4 .. local5, itemref)
    end
    return
end