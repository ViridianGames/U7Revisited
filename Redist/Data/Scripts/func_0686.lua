require "U7LuaFuncs"
-- Casts the "In Jux Por Ylem" spell, creating a trap or hazardous object at a selected location.
function func_0686(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 or eventid == 4 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@In Jux Por Ylem@", itemref)
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 287, itemref) -- Unmapped intrinsic
            local3 = add_item(itemref, {17505, 17530, 17514, 17511, 17505, 17519, 17505, 8037, 65, 8536, local1, 7769})
        else
            local3 = add_item(itemref, {1542, 17493, 17514, 17505, 17519, 17505, 8549, local1, 7769})
        end
    end
    return
end