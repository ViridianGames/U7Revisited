-- Processes container items and applies effects based on conditions.
function func_070B(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if not external_0944H(itemref) then -- Unmapped intrinsic
        local0 = get_item_data(itemref)
        local1 = false
        local2 = external_0025H(itemref) -- Unmapped intrinsic
        if not external_0036H(external_001BH(-356)) then -- Unmapped intrinsic
            local2 = set_item_data(local0)
            local3 = get_container_items(-359, -359, -1, external_001BH(-356)) -- Unmapped intrinsic
            for local4 in ipairs(local3) do
                local5 = local4
                local6 = local5
                if local1 == 0 then
                    if not external_08E9H(local6) then -- Unmapped intrinsic
                        local2 = external_0025H(local6) -- Unmapped intrinsic
                        local7 = get_item_data(external_001BH(-356)) -- Unmapped intrinsic
                        local2 = set_item_data(local7)
                    end
                elseif local1 == 1 then
                    if not external_08EAH(local6) then -- Unmapped intrinsic
                        local2 = external_0025H(local6) -- Unmapped intrinsic
                        local7 = get_item_data(external_001BH(-356)) -- Unmapped intrinsic
                        local2 = set_item_data(local7)
                    end
                elseif local1 == 2 then
                    if local6 == external_001BH(-356) and is_item_active(local6) then -- Unmapped intrinsic
                        local2 = external_0025H(local6) -- Unmapped intrinsic
                        local7 = get_item_data(external_001BH(-356)) -- Unmapped intrinsic
                        local2 = set_item_data(local7)
                    end
                end
                local1 = local1 + 1
            end
            local2 = external_0025H(itemref) -- Unmapped intrinsic
        end
    end
    local8 = add_item(itemref, {1803, 17493, 17443, 7724})
    return
end