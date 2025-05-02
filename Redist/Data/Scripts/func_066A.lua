-- Casts the "An Grav" spell, dispelling electrical or energy effects on a selected target.
function func_066A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        local2 = {902, 900, 895, 768}
        bark(itemref, "@An Grav@")
        if not external_0906H(local1) then -- Unmapped intrinsic
            local3 = add_item(itemref, {17514, 17520, 8559, local1, 8025, 65, 7768})
            for local4 in ipairs(local0) do
                local5 = local4
                local6 = local5
                if get_item_type(local0) == local6 then
                    local3 = external_0025H(local0) -- Unmapped intrinsic
                    if local3 then
                        local3 = set_item_data(get_item_data(-358))
                        set_object_frame(local0, 0)
                    end
                end
            end
        else
            local3 = add_item(itemref, {1542, 17493, 17514, 17520, 8559, local1, 7769})
        end
    end
    return
end