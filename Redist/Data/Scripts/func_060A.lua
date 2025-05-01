-- Manages a horse racing game mechanic, determining the winning horse's color and announcing results based on frame data and bets.
function func_060A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17

    if eventid == 2 then
        return
    end

    if get_schedule(-232) == 9 then
        set_schedule(232, 10)
    end

    local0 = add_item(0, 7, 520, itemref)
    local1 = add_item(0, 5, 644, local0)
    local2 = 0
    local3 = 0
    local4 = get_item_frame(itemref)
    local5 = math.floor(local4 / 4)

    if local5 == 0 then
        local2 = -3
        local3 = -1
        local6 = "Blue"
    elseif local5 == 1 then
        local2 = 0
        local3 = 0
        local6 = "Black"
    elseif local5 == 2 then
        local2 = -1
        local3 = 0
        local6 = "White"
    elseif local5 == 3 then
        local2 = -2
        local3 = 0
        local6 = "Purple"
    elseif local5 == 4 then
        local2 = -3
        local3 = 0
        local6 = "Orange"
    elseif local5 == 5 then
        local2 = 0
        local3 = -1
        local6 = "Green"
    elseif local5 == 6 then
        local2 = -1
        local3 = -1
        local6 = "Red"
    elseif local5 == 7 then
        local2 = -2
        local3 = -1
        local6 = "Yellow"
    end

    local7 = false
    if not npc_in_party(-232) then
        local8 = {}
        local9 = ""
    else
        bark(232, "@Didst thou win?@")
    end

    if get_flag(6) then
        local10 = 14
    else
        local10 = 7
    end

    for local11 in ipairs(local8) do
        local12 = local11
        local13 = get_item_data(local12)
        local14 = get_item_data(local0)
        if local13[1] + local2 == local14[1] and local13[2] + local3 == local14[2] then
            set_schedule(local12, 11)
            local15 = get_item_quality(local12, 0)
            local16 = local15 * local10
            while local16 > 100 do
                local17 = add_item(local15, 644)
                if local17 then
                    set_item_quality(100, local17)
                    set_item_owner(local13, local17)
                end
                local16 = local16 - 100
            end
            local17 = add_item(local16, 644)
            if local17 then
                set_item_quality(local16, local17)
                set_item_owner(local13, local17)
            end
            set_schedule(232, local12)
            if local12 then
                bark(232, "@A winner on " .. local6 .. ".@")
            end
            local7 = true
        end
        remove_item(local12)
    end

    if not local7 and local12 then
        bark(232, "@It is " .. local6 .. ".@")
    end

    return
end