--- Best guess: Triggers a dialogue with the Time Lord (func_0269) when an hourglass is used, if specific conditions (flag 4) are met.
function func_0347(eventid, itemref)
    local var_0000

    if eventid == 1 then
        var_0000 = get_object_frame(itemref)
        if var_0000 == 1 and not get_flag(4) then
            func_0269(617, unknown_001BH(itemref))
            set_object_quality(itemref, 67)
        end
    end
end