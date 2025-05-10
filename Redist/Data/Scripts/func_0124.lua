--- Best guess: Manages a seating interaction on a barge or chair, assigning party members to seats based on proximity and state.
function func_0124(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014

    if eventid == 1 then
        if unknown_0058H(objectref) then
            var_0000 = func_080CH(0, objectref)
            if var_0000 == 652 or var_0000 == 840 then
                if not unknown_0088H(10, objectref) then
                    if var_0000 == 652 then
                        calle_028CH(objectref)
                    elseif var_0000 == 840 then
                        calle_0348H(objectref)
                    end
                else
                    var_0001 = unknown_08B3H(objectref)
                end
            end
        else
            func_080AH(292, objectref)
            var_0002 = unknown_0019H(-356, objectref) + 15
            var_0001 = unknown_0002H(var_0002, {292, 17493, 7715}, objectref)
        end
    elseif eventid == 2 then
        var_0003 = unknown_0018H(-356)
        var_0004 = {2469, 2615, 2277, 2727, 2517, 2615, 2517, 2791}
        var_0005 = {2181, 2775}
        var_0006 = 0
        if var_0003[1] == var_0005[1] and var_0003[2] == var_0005[2] and get_flag(743) == false then
            set_flag(743, true)
            var_0007 = unknown_0053H(-1, 0, 0, 0, var_0005[2] + 1, var_0005[1] + 1, 17)
            set_object_quality(objectref, 62)
            start_endgame()
            var_0007 = unknown_0024H(895)
            if not var_0007 then
                unknown_0089H(18, var_0007)
                var_0001 = unknown_0026H(var_0005)
            end
            abort()
        end
        var_0008 = 1
        while var_0003[1] == var_0004[var_0008] and var_0003[2] == var_0004[var_0008 + 1] do
            var_0008 = func_080BH(var_0008)
            var_0004[var_0008] = var_0008
            var_0004[var_0008 + 1] = var_0008 + 1
        end
        var_0008 = func_080BH(var_0008)
        if var_0008 > 1 then
            var_0009 = get_party_members()
            var_000A = {}
            var_000B = {}
            var_000C = {}
            var_000D = unknown_0018H(-356)
            var_000E = 1
            for var_000F in ipairs(var_0009) do
                var_0010 = unknown_0018H(var_0011)
                var_000A[var_000E] = var_0010[1] - var_000D[1]
                var_000B[var_000E] = var_0010[2] - var_000D[2]
                var_000C[var_000E] = var_0011
                var_0012 = unknown_006BH(var_0011)
                var_000E = var_000E + 1
            end
            func_003EH(var_0006, -357)
            var_000D = unknown_0018H(-356)
            var_000E = 1
            for var_0013 in ipairs(var_0009) do
                var_000D[3] - var_000D[2] = var_000B[var_000E]
                var_000D[3] - var_000D[1] = var_000A[var_000E]
                func_003EH(var_000C[var_000E], var_0011)
                unknown_006CH(var_000C[var_000E], var_0011)
                var_000E = var_000E + 1
            end
        end
    end
end