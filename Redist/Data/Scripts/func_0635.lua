-- Manages oven interactions, triggering banter and creating bread when baking is complete.
function func_0635(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 3 then
        local0 = add_item(itemref, 0, 0, 658)
        if local0 then
            local1 = add_item(local0, 60, 1589, {17493, 7715})
            if get_random(1, 2) == 1 then
                external_08FEH("@Do not over cook it!@") -- Unmapped intrinsic
            end
        end
    elseif eventid == 2 then
        local2 = get_item_data(itemref)
        local3 = add_item(itemref, 0, 2, 831)
        if #local3 > 0 then
            remove_item(itemref)
            local4 = get_item_frame(377)
            if local4 then
                set_item_frame(itemref, 0)
                local1 = set_item_data(local2)
                local5 = get_random(1, 3)
                if local5 == 1 then
                    external_08FEH("@I believe the bread is ready.@") -- Unmapped intrinsic
                elseif local5 == 2 then
                    external_08FEH("@Mmm... Smells good.@") -- Unmapped intrinsic
                end
            end
        end
    end
    return
end