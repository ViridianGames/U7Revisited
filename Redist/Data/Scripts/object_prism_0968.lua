--- Best guess: Triggers different external functions based on an object's frame, possibly for a multi-state mechanism or trap.
function object_prism_0968(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 0 then
            -- call [0000] (0805H, unmapped)
            utility_event_0773(objectref)
        elseif var_0000 == 1 then
            -- call [0001] (0807H, unmapped)
            utility_event_0775(objectref)
        elseif var_0000 == 2 then
            -- call [0002] (0803H, unmapped)
            utility_event_0771(objectref)
        end
    elseif eventid == 2 then
        var_0001 = get_object_position(objectref)
        var_0002 = sprite_effect(-1, 0, 0, 0, aidx(var_0001, 2) - 3, aidx(var_0001, 1) - 3, 7)
    end
    return
end