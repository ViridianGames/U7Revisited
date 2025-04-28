require "U7LuaFuncs"
-- Casts the "Des Sanct" spell, lowering the target's defense.
function func_0658(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@Des Sanct@", itemref)
        if external_0906H(local1) and local0[1] ~= 0 then -- Unmapped intrinsic
            local2 = external_0041H(local0, 281, itemref) -- Unmapped intrinsic
            local3 = add_item(itemref, {17530, 17514, 17520, 8037, 67, 8536, local1, 7769})
        else
            local3 = add_item(itemref, {1542, 17493, 17514, 17520, 8549, local1, 7769})
        end
    end
    return
end