-- Casts the "In Sanct Grav" spell, creating a protective electrical barrier at a selected location.
function func_067B(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    local0 = false
    if eventid == 1 then
        local1 = item_select_modal() -- Unmapped intrinsic
        bark(itemref, "@In Sanct Grav@")
        local2 = local1[2] + 1
        local3 = local1[3] + 1
        local4 = local1[4]
        local5 = {local4, local3, local2}
        local6 = external_0085H(768, local5, 0) -- Unmapped intrinsic
        if not external_0906H() and local6 then -- Unmapped intrinsic
            local7 = add_item(itemref, {17511, 17510, 7781})
            local8 = get_item_by_type(768) -- Unmapped intrinsic
            if local8 then
                local9 = set_item_data(local5)
                if local9 then
                    local10 = 200
                    set_item_quality(local8, local10)
                    local9 = add_item(local8, local10, 8493)
                else
                    local0 = true
                end
            else
                local0 = true
            end
        else
            local0 = true
        end
        if local0 then
            local7 = add_item(itemref, {1542, 17493, 17511, 17510, 7781})
        end
    end
    return
end