-- Function 0887: Compare and adjust party stats
function func_0887(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    local3 = false
    local4 = false
    local5 = false
    local6 = false
    local7 = false
    local8 = false
    local9 = false
    local10 = false
    local11 = false
    if itemref[1] ~= eventid[1] then
        local3 = true
    elseif itemref[1] < eventid[1] then
        eventid[1] = eventid[1] - 1
        local4 = true
    else
        eventid[1] = eventid[1] + 1
        local5 = true
    end
    if itemref[2] ~= eventid[2] then
        if itemref[2] < eventid[2] then
            eventid[2] = eventid[2] - 1
            if not local4 then
                local8 = true
                local4 = false
            else
                if not local5 then
                    local10 = true
                    local5 = false
                else
                    local6 = true
                end
            end
        else
            eventid[2] = eventid[2] + 1
            if not local4 then
                local9 = true
                local4 = false
            else
                if not local5 then
                    local11 = true
                    local5 = false
                else
                    local7 = true
                end
            end
        end
    else
        move_object(-1, 0, 0, 0, eventid[2] - 1, itemref[1] - 1, 4)
        local12 = get_random(9)
        local12 = call_0024H(275)
        _SetItemFrame(6, local12)
        call_0089H(151, local12)
        _SetItemQuality(151, local12)
        call_0026H(eventid)
        _SetItemQuality(local12)
        call_0888H(local12)
        delete_item(local12)
        delete_item(itemref)
        set_item_glow(itemref)
        local0 = {17493, 7715}
        set_return(0)
    end
    if not local4 and not local5 then
        local15 = _Random2(1, -1)
        eventid[2] = eventid[2] + local15
    end
    if not local6 and not local7 then
        local15 = _Random2(1, -1)
        eventid[1] = eventid[1] + local15
    end
    if not local10 then
        if local15 == 1 then
            eventid[2] = eventid[2] + 1
        elseif local15 == 2 then
            eventid[1] = eventid[1] - 1
        end
    end
    if not local8 then
        if local15 == 1 then
            eventid[2] = eventid[2] + 1
        elseif local15 == 2 then
            eventid[1] = eventid[1] + 1
        end
    end
    if not local11 then
        if local15 == 1 then
            eventid[2] = eventid[2] - 1
        elseif local15 == 2 then
            eventid[1] = eventid[1] - 1
        end
    end
    if not local9 then
        if local15 == 1 then
            eventid[2] = eventid[2] - 1
        elseif local15 == 2 then
            eventid[1] = eventid[1] + 1
        end
    end
    set_return(eventid)
end