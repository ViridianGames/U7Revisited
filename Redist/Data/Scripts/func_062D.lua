--- Best guess: Manages a spinning wheel mechanic, converting wool (ID 651) into thread, with dialogue prompting correct item use and updating item states.
function func_062D(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 7 then
        var_0000 = unknown_006EH(itemref)
        if not var_0000 then
            var_0001 = unknown_0827H(itemref, -356)
            var_0002 = unknown_0018H(itemref)
            var_0003 = unknown_0025H(itemref)
            if not var_0003 then
                var_0003 = unknown_0036H(-356)
                if not var_0003 then
                    var_0003 = unknown_0026H(var_0002)
                    unknown_006AH(4)
                    return
                else
                    var_0003 = unknown_0001H(-356, {1581, 17493, 17505, 17516, 8449, var_0001, 7769})
                end
            end
        else
            unknown_007EH()
        end
    elseif eventid == 2 or var_0000 then
        var_0004 = _ItemSelectModal()
        var_0005 = get_object_shape(var_0004)
        if var_0005 == 651 then
            var_0006 = {1, 1}
            var_0007 = {0, 0}
            var_0008 = -1
            unknown_0828H(7, var_0004, 651, var_0008, var_0007, var_0006, var_0004)
        else
            var_0009 = "@Why dost thou not spin that wool into thread?@"
            unknown_08FFH(var_0009)
        end
    end
end