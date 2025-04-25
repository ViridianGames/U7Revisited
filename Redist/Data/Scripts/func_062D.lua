-- Manages wool spinning on a spinning wheel, converting wool to thread if the correct item is selected.
function func_062D(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 7 then
        local0 = is_item_active(itemref) -- Unmapped intrinsic
        if not local0 then
            local1 = external_0827H(itemref, -356) -- Unmapped intrinsic
            local2 = get_item_data(itemref)
            local3 = external_0025H(itemref) -- Unmapped intrinsic
            if local3 then
                local3 = external_0036H(-356) -- Unmapped intrinsic
                if not local3 then
                    local3 = set_item_data(local2)
                    external_006AH(4) -- Unmapped intrinsic
                    return
                end
                local3 = add_item(-356, {1581, 17493, 17505, 17516, 8449, local1, 7769})
            end
        else
            external_007EH() -- Unmapped intrinsic
        end
    elseif eventid == 2 or local0 then
        local4 = item_select_modal() -- Unmapped intrinsic
        local5 = get_item_type(local4)
        if local5 == 651 then
            local6 = {-2, -1, 0}
            local7 = {1, 1, 1}
            local8 = -1
            local9 = add_item(local4, 7, 651, local8, local7, local6)
        else
            local9 = "@Why dost thou not spin that wool into thread?@"
            external_08FFH(local9) -- Unmapped intrinsic
        end
    end
    return
end