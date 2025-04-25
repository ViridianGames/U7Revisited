-- Casts the "Wis Jux" spell, revealing traps and setting their quality to trigger effects.
function func_064A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        item_say("@Wis Jux@", itemref)
        if not external_0906H() then -- Unmapped intrinsic
            local0 = add_item(itemref, {17511, 8037, 66, 7768})
            local1 = external_08F6H(-356) -- Unmapped intrinsic
            local2 = local1 + 21
            local3 = add_item(local0, 176, local2, 200)
            for local4 in ipairs(local3) do
                local5 = local4
                local6 = local5
                local0 = add_item(local6, 5, 1610, {17493, 7715})
            end
            local7 = add_item(local0, 176, local2, 522)
            local8 = add_item(local0, 176, local2, 800)
            for local4 in ipairs({local7, local8}) do
                local5 = local4
                local6 = local5
                if get_item_quality(local6) == 255 then
                    local0 = add_item(local6, 5, 1610, {17493, 7715})
                end
            end
        else
            local0 = add_item(itemref, {1542, 17493, 17511, 7781})
        end
    elseif eventid == 2 then
        local0 = get_item_data(itemref)
        create_object(-1, 0, 0, 0, local0[2], local0[1], 16) -- Unmapped intrinsic
    end
    return
end