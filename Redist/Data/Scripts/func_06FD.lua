--- Best guess: Manages item interactions for event ID 2, adjusting positions and triggering effects for items with specific quality and frame, likely part of a forge or environmental mechanic.
function func_06FD(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014

    if eventid == 2 then
        var_0000 = false
        var_0001 = false
        var_0002 = unknown_0035H(0, 80, 797, unknown_001BH(356))
        for i = 1, #var_0002 do
            var_0005 = var_0002[i]
            var_0006 = unknown_0014H(var_0005)
            var_0007 = unknown_0012H(var_0005)
            if var_0006 == 150 and var_0007 == 4 then
                var_0000 = var_0005
                var_0001 = unknown_0018H(var_0005)
            end
        end
        var_0008 = unknown_0018H(objectref)
        var_0009 = unknown_0887H(var_0000, var_0001, var_0008)
        if not var_0009 then
            unknown_006FH(var_0000)
        end
        var_0010 = unknown_0024H(895)
        unknown_0013H(0, var_0010)
        unknown_0089H(18, var_0010)
        if not unknown_0085H(0, 721, var_0009) then
            var_0011 = unknown_0026H(var_0009)
        elseif not unknown_0085H(0, 721, {var_0009[1], var_0009[2] + 1, var_0009[3]}) then
            var_0011 = unknown_0026H({var_0009[1], var_0009[2] + 1, var_0009[3]})
        elseif not unknown_0085H(0, 721, {var_0009[1], var_0009[2] - 2, var_0009[3]}) then
            var_0011 = unknown_0026H({var_0009[1], var_0009[2] - 2, var_0009[3]})
        else
            unknown_0053H(-1, 0, 0, 0, var_0009[2], var_0009[1], 4)
            unknown_000FH(9)
            var_0012 = unknown_0024H(275)
            unknown_0013H(6, var_0012)
            unknown_0089H(18, var_0012)
            var_0011 = unknown_0015H(151, var_0012)
            var_0011 = unknown_0026H(var_0009)
            unknown_0888H(var_0012)
            unknown_006FH(var_0000)
            unknown_006FH(var_0012)
        end
        var_0013 = unknown_0002H(9, {17493, 7715, 1800}, var_0010)
        var_0008 = unknown_0018H(var_0010)
        var_0009 = unknown_0887H(var_0000, var_0001, var_0008)
        if not var_0009 then
            unknown_006FH(var_0000)
        end
        var_0010 = unknown_0024H(895)
        unknown_0013H(0, var_0010)
        unknown_0089H(18, var_0010)
        if not unknown_0085H(0, 721, var_0009) then
            var_0011 = unknown_0026H(var_0009)
        elseif not unknown_0085H(0, 721, {var_0009[1], var_0009[2] + 1, var_0009[3]}) then
            var_0011 = unknown_0026H({var_0009[1], var_0009[2] + 1, var_0009[3]})
        elseif not unknown_0085H(0, 721, {var_0009[1], var_0009[2] - 2, var_0009[3]}) then
            var_0011 = unknown_0026H({var_0009[1], var_0009[2] - 2, var_0009[3]})
        else
            unknown_0053H(-1, 0, 0, 0, var_0009[2], var_0009[1], 4)
            unknown_000FH(9)
            var_0012 = unknown_0024H(275)
            unknown_0013H(6, var_0012)
            unknown_0089H(18, var_0012)
            var_0011 = unknown_0015H(151, var_0012)
            var_0011 = unknown_0026H(var_0009)
            unknown_0888H(var_0012)
            unknown_006FH(var_0000)
            unknown_006FH(var_0012)
        end
        var_0013 = unknown_0002H(9, {17493, 7715, 1800}, var_0010)
        var_0014 = unknown_0001H({1789, 17493, 7715}, var_0010)
    end
    return
end