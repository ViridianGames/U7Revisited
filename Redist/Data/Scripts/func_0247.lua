--- Best guess: Manages a bedroll, deploying it as a bed (ID 1011) if there’s space, or reverting to item form when used or examined.
function func_0247(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 and not unknown_006EH(objectref) then
        var_0000 = unknown_0018H(objectref)
        if get_object_frame(objectref) == 0 then
            var_0001 = unknown_0025H(objectref)
            if not var_0001 then
                var_0002 = unknown_0085H(17, 1011, var_0000)
                var_0001 = unknown_0026H(var_0000)
                if var_0002 and var_0001 then
                    unknown_007EH()
                    var_0003 = {-1, -1, -1, 0, 0, 0, 1, 1, 1}
                    var_0004 = {1, 0, -1, 1, 0, -1, 1, 0, -1}
                    unknown_005CH(-356)
                    unknown_0828H(7, objectref, 583, -1, var_0004, var_0003, objectref)
                else
                    var_0000[2] = var_0000[2] - 5
                    unknown_08FFH("@There is no room for thy bedroll there.@")
                end
            end
        end
    elseif eventid == 7 then
        var_0001 = unknown_0001H({17505, 17516, 17456, 7769}, -356)
        var_0001 = unknown_0001H({583, 8021, 2, 7719}, objectref)
    elseif eventid == 2 then
        set_object_shape(objectref, 1011)
        get_object_frame(objectref, 17)
    end
end