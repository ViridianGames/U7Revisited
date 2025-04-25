-- Casts the "Ort Grav" spell, creating an electrical or energy effect on a selected target.
function func_0661(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 or eventid == 4 then
        local0 = item_select_modal() -- Unmapped intrinsic
        item_say("@Ort Grav@", itemref)
        local1 = external_092DH(local0) -- Unmapped intrinsic
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = external_0041H(local0, 807, itemref) -- Unmapped intrinsic
            local2 = add_item(itemref, {17505, 17530, 17514, 17514, 8048, 65, 17496, 17519, 8549, local1, 7769})
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17520, 17519, 8549, local1, 7769})
        end
    end
    return
end