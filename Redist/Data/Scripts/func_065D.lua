require "U7LuaFuncs"
-- Casts the "Vas Wis" spell, granting enhanced perception or revealing hidden elements.
function func_065D(eventid, itemref)
    local local0

    if eventid == 1 then
        item_say("@Vas Wis@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {1629, 17493, 17519, 17520, 8047, 67, 7768})
        else
            local0 = add_item(itemref, {1542, 17493, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        local0 = external_0048H() -- Unmapped intrinsic
    end
    return
end