-- Function 0815: Handle door locking
function func_0815(eventid, itemref)
    local local0, local1, local2, local3, local4

    local1 = call_081BH(eventid)
    local2 = _GetItemQuality(itemref)
    local3 = -1
    if local1 == 0 then
        if local2 == 228 then
            set_flag(737, false)
        elseif local2 == 247 then
            set_flag(738, false)
        end
        local3 = 2
    elseif local1 == 1 then
        local4 = "@Excuse me, the door is already open. Is it not rather futile to lock it now?@"
        add_dialogue(itemref, local4)
    elseif local1 == 2 then
        if local2 == 228 then
            set_flag(737, true)
        elseif local2 == 247 then
            set_flag(738, true)
        end
        local3 = 0
    elseif local1 == 3 and _Random2(10, 1) == 1 then
        local4 = "@Excuse me, the door appears magically locked. Is it not rather difficult to unlock it with a key?@"
        add_dialogue(itemref, local4)
    end
    if local3 ~= -1 then
        call_081CH(local3, eventid)
    end
end