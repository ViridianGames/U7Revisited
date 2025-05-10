--- Best guess: Triggers different external functions based on an object’s frame, possibly for a multi-state mechanism or trap.
function func_03C8(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 0 then
            -- call [0000] (0805H, unmapped)
            unknown_0805H(objectref)
        elseif var_0000 == 1 then
            -- call [0001] (0807H, unmapped)
            unknown_0807H(objectref)
        elseif var_0000 == 2 then
            -- call [0002] (0803H, unmapped)
            unknown_0803H(objectref)
        end
    elseif eventid == 2 then
        var_0001 = unknown_0018H(objectref)
        var_0002 = unknown_0053H(-1, 0, 0, 0, aidx(var_0001, 2) - 3, aidx(var_0001, 1) - 3, 7)
    end
    return
end