require "U7LuaFuncs"
-- Manages the end of a horse race, resetting horse frames, handling bets, and announcing the winning lane.
function func_060C(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23

    if get_schedule(-232) == 9 then
        set_schedule(-232, 10)
    end

    if not npc_in_party(-232) then
        local0 = add_item(0, 50, 764, -356)
        for local1 in ipairs(local0) do
            local2 = local1
            local3 = local2
            set_item_frame(local3, 0)
            trigger_action(local3) -- Unmapped intrinsic
        end
        return
    end

    local4 = add_item(0, 7, 644, itemref)
    local5 = get_item_data(itemref)
    local6 = 0
    local7 = get_item_by_type(763)
    for local8 in ipairs(local7) do
        local9 = local8
        local10 = get_item_frame(local9)
        if local10 == 1 or local10 == 2 then
            local6 = local9
        end
    end

    local7 = get_item_by_type(763)
    if get_flag(6) then
        local12 = 6
    else
        local12 = 3
    end

    local13 = get_item_data(local6)
    local14 = get_container_items(-356, {763, 899, 1791}, {753, 1595, -356})
    set_flag(34, local14)
    if not local14 then
        local15 = add_item(4, 90, -359, -356)
        local15 = set_schedule(-356, local15)
        for local16 in ipairs(local15) do
            local17 = local16
            local18 = get_item_data(local17)
            if local18[1] <= local13[1] and local18[1] >= local13[1] - 5 and local18[2] + 8 <= local13[2] and local18[2] - 8 >= local13[2] then
                local19 = get_item_quality(local19, local17)
                local20 = local19 * local12
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
                local22 = math.floor((local13[2] - local5[2]) / 4)
                local23 = "@A winnah in lane " .. local22 .. "!@"
                item_say(local23, -232, 1)
                remove_item(local17)
            end
        end
        if not get_flag(34) then
            set_flag(34, true)
        elseif not get_flag(35) then
            set_flag(35, true)
        elseif not get_flag(36) and get_flag(35) then
            set_flag(34, false)
            set_flag(35, false)
            set_flag(36, false)
            local0 = get_item_by_type(764)
            for local16 in ipairs(local0) do
                local17 = local16
                set_item_frame(local17, 0)
            end
        end
    end

    return
end