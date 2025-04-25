-- Handles bed interactions, preventing sleep during combat and managing nap time.
function func_0800(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    external_007EH() -- Unmapped intrinsic
    set_flag(744, false)
    local1 = external_0900H() -- Unmapped intrinsic
    if not external_008EH() then -- Unmapped intrinsic
        switch_talk_to(local1, 0)
        local2 = get_player_name(local1) -- Unmapped intrinsic
        if local1 == -356 then
            say("\"This is no time to sleep! Look alive!\"")
        else
            say(local2 .. " glares. \"This is no time to sleep! Look alive!\"")
        end
        if not external_0801H(local0) then -- Unmapped intrinsic
            external_0624H(local0) -- Unmapped intrinsic
        end
        hide_npc(local1)
    else
        local3 = get_item_frame(local0)
        local4 = get_item_type(local0)
        if local3 > 3 and not external_0801H(local0) then -- Unmapped intrinsic
            local5 = get_item_data(local0)
            local6 = external_0035H(0, 2, local4, local0) -- Unmapped intrinsic
            for local7 in ipairs(local6) do
                local8 = local7
                local9 = local8
                if get_item_frame(local9) <= 2 then
                    local10 = get_item_data(local9)
                    if local10[1] == local5[1] and local10[2] == local5[2] and local10[3] + 1 == local5[3] then
                        local0 = local9
                    end
                end
            end
        elseif external_0801H(itemref) then -- Unmapped intrinsic
            local11 = add_item(external_001BH(-356), {30, 17492, 7715}) -- Unmapped intrinsic
        end
        local12 = external_093CH(get_party_members(), external_001BH(-356)) -- Unmapped intrinsic
        external_001DH(external_001BH(-356), 14) -- Unmapped intrinsic
        external_0077H(local0) -- Unmapped intrinsic
    end
    return
end