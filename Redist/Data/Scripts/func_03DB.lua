--- Best guess: Spawns a screaming creature (ID 992) with a chance to cry out, possibly for a trap or ambush.
function func_03DB(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        -- calli 007E, 0 (unmapped)
        unknown_007EH()
        var_0000 = {0, 8006, 3, 8006, 4, 8006, 17, 8024, 4, 8006, 3, 8006, 0, 8006, 1, 8006, 2, 8006, 17, 8024, 2, 8006, 1, 8006, 0, 7750}
        var_0001 = unknown_0001H(var_0000, objectref)
        if random2(10, 1) == 1 then
            var_0002 = unknown_0018H(objectref)
            set_object_shape(objectref, 992)
            var_0003 = unknown_0024H(730)
            unknown_0089H(18, var_0003)
            unknown_0089H(11, var_0003)
            if var_0003 then
                var_0001 = unknown_0026H(var_0002)
                bark(var_0003, "@Whaaahh!!@")
            end
        end
    end
    return
end