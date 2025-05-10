--- Best guess: Manages a spinning wheel, checking for wool (type 873) to produce thread (type 653), with a message if empty, and updating item frame randomly.
function func_028B(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 7 then
        var_0000 = unknown_0035H(0, 1, 873, -356)
        var_0001 = 0
        if #var_0000 > 0 then
            var_0002 = unknown_0001H({12, -1, 17419, 17515, 8044, 6, 7769}, -356)
            var_0001 = 3
        end
        unknown_005CH(objectref)
        var_0002 = unknown_0002H(objectref, {var_0001, 651, 8021, 12, -4, 7947, 6, 17496, 17409, 8014, 0, 7750})
    elseif eventid == 2 then
        var_0003 = unknown_002AH(-359, -359, 653, -356)
        if var_0003 then
            unknown_006FH(var_0003)
        end
        var_0004 = unknown_0024H(654)
        if var_0004 then
            unknown_0089H(18, var_0004)
            unknown_0089H(11, var_0004)
            unknown_0013H(math.random(0, 9), var_0004)
            var_0005 = unknown_0018H(objectref)
            var_0005[1] = var_0005[1] + 1
            var_0005[2] = var_0005[2] + 1
            var_0002 = unknown_0026H(var_0005)
        end
    elseif eventid == 1 then
        var_0006 = "@I suspect spinning the wool will be more fruitful than spinning an empty wheel.@"
        unknown_08FFH(var_0006, objectref)
    end
    return
end