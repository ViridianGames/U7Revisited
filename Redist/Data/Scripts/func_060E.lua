-- Handles resurrection of party members or NPCs, playing music, adjusting positions, and managing game state.
function func_060E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24, local25, local26, local27, local28, local29, local30

    if eventid == 4 then
        set_schedule(0, 1, 12)
        play_music(0, 255)
        play_music(0, 17)
        external_0083() -- Unmapped intrinsic
        local0 = resurrect_actor(itemref) -- Unmapped intrinsic
        for local1 in ipairs(local0) do
            local2 = local1
            local3 = local2
            local4 = resurrect_party_member(local3) -- Unmapped intrinsic
        end
        local4 = add_item(5, {1550, 17493, 7715}, itemref)
        return
    end

    if eventid == 2 then
        local5 = get_item_type(itemref)
        local6 = get_item_data(itemref)
        set_flag(57, false)
        if not get_flag(87) then
            local14 = get_container_items(-356, {763, 899, 1791}, {753, 1595, -356})
            set_flag(58, local14)
            if not local14 then
                local15 = add_item(4, 90, -359, -356)
                local15 = set_schedule(356, local15)
                for local16 in ipairs(local15) do
                    local17 = local16
                    local18 = get_item_data(local17)
                    if local18[1] <= local6[1] and local18[1] >= local6[1] - 5 and local18[2] + 8 <= local6[2] and local18[2] - 8 >= local6[2] then
                        local19 = get_item_quality(local19, local17)
                        local20 = local19 * 6
                        while local20 > 100 do
                            local21 = add_item(100, 644)
                            if local21 then
                                set_item_quality(100, local21)
                                set_item_owner(local18, local21)
                            end
                            local20 = local20 - 100
                        end
                        local21 = add_item(local20, 644)
                        if local21 then
                            set_item_quality(local20, local21)
                            set_item_owner(local18, local21)
                        end
                        set_schedule(local17, 11)
                        local22 = math.floor((local6[2] - local5[2]) / 4)
                        local23 = "@A winnah in lane " .. local22 .. "!@"
                        item_say(local23, -232, 1)
                        remove_item(local17)
                    end
                end
                if not get_flag(58) then
                    set_flag(58, true)
                elseif not get_flag(59) then
                    set_flag(59, true)
                elseif not get_flag(60) and get_flag(59) then
                    set_flag(58, false)
                    set_flag(59, false)
                    set_flag(60, false)
                    local0 = get_item_by_type(764)
                    for local16 in ipairs(local0) do
                        local17 = local16
                        set_item_frame(local17, 0)
                    end
                end
            end
        else
            external_0073() -- Unmapped intrinsic
        end
    end

    return
end