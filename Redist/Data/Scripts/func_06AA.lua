--- Best guess: Manages the Avatar’s initial appearance via a moongate, creating and positioning it relative to the Avatar’s location.
function func_06AA(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 2 then
        var_0000 = unknown_0024H(157)
        if var_0000 then
            unknown_006CH(32, 356)
            var_0001 = unknown_0018H(356)
            var_0001[1] = var_0001[1] + 1
            var_0001[2] = var_0001[2] + 1
            var_0002 = unknown_0026H(var_0001)
            if var_0002 then
                var_0002 = unknown_0001H(7981, {3, 1, 17419, 8016, 4, 8006, 5, 1, 17419, 8014, 4, 8006, 1560, 8021, 10, 1, 17419, 8014, 0, 7750}, var_0000)
            end
        end
    end
    return
end