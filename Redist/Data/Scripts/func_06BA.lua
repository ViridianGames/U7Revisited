--- Best guess: Applies effects to party members with non-zero strength, displaying random distress messages and triggering a sequence when event ID 3 is received.
function func_06BA(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 3 then
        var_0000 = unknown_0023H()
        for i = 1, #var_0000 do
            var_0003 = var_0000[i]
            if not unknown_004AH(unknown_0020H(0, var_0003), unknown_0014H(objectref)) then
                var_0004 = unknown_001BH(var_0003)
                unknown_005CH(var_0004)
                unknown_0620H(var_0004)
                var_0005 = unknown_0002H(25, 1567, {17493, 7715}, var_0004)
                var_0005 = unknown_0001H({8033, 4, 17447, 8046, 4, 17447, 8045, 4, 17447, 8044, 5, 17447, 7715}, var_0004)
                if not unknown_0937H(var_0004) then
                    unknown_0904H({"@Yuk!@", "@Oh no!@", "@Eeehhh!@", "@Ohh!@"}, var_0004)
                end
                var_0005 = unknown_0002H(17, 1722, {17493, 7715}, var_0004)
            end
        end
    elseif eventid == 2 then
        var_0006 = 0
        var_0007 = 0
        while var_0006 < 16 do
            if var_0007 == 0 then
                var_0007 = var_0006 + unknown_0010H(3, 0)
            else
                var_0007 = {var_0007, var_0006 + unknown_0010H(3, 0)}
            end
            var_0006 = var_0006 + 4
        end
        for i = 1, #var_0007 do
            var_0008 = var_0007[i]
            if var_0008 then
                var_0005 = unknown_0024H(912)
                if var_0005 then
                    unknown_0089H(18, var_0005)
                    var_000C = unknown_0026H(unknown_0018H(objectref))
                    unknown_0013H(var_0008, var_0005)
                end
            end
        end
    end
    return
end