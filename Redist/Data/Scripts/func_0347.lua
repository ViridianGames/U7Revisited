--- Best guess: Triggers a dialogue with the Time Lord (func_0269) when an hourglass is used, if specific conditions (flag 4) are met.
function func_0347(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 1 and not get_flag(4) then
            func_0269(617, get_npc_name(objectref))
            set_object_quality(objectref, 67)
        end
    end
end