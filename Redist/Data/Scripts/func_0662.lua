-- Casts the "Kal Por Ylem" spell, teleporting an object to a random location if it is not a specific type (330).
function func_0662(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = get_item_data(itemref)
        item_say("@Kal Por Ylem@", itemref)
        if not external_0906H() and get_item_type(local0) ~= 330 and external_0058H(-356) and not get_flag(39) then -- Unmapped intrinsic
            local2 = add_item(local0, 1554, {17493, 7715})
            local2 = add_item(itemref, {17514, 17520, 7791})
            create_object(-1, 0, 0, 0, local1[2], local1[1], 13) -- Unmapped intrinsic
        else
            local2 = add_item(itemref, {1542, 17493, 17514, 17520, 7791})
        end
    end
    return
end