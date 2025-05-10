--- Best guess: Manages a crafting or transformation mechanic, checking item quality and positions, updating item states, and potentially generating new items based on random outcomes.
function func_060D(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011

    if eventid ~= 2 then
        return
    end

    var_0000 = unknown_0035H(0, 10, 410, objectref)
    var_0001 = _get_object_quality(var_0000)
    var_0002 = {915, 916, 914}
    var_0003 = var_0002[var_0001]
    if random2(20, 1) == 1 then
        var_0004 = unknown_0018H(objectref)
        var_0005 = unknown_0024H(var_0003)
        if var_0005 then
            unknown_0089H(18, var_0005)
            get_object_frame(var_0005, 0)
            var_0006 = unknown_0026H({var_0004[2], var_0004[1] - 9})
        end
    end

    var_0007 = unknown_0035H(0, 10, 359, objectref)
    var_0008 = unknown_0018H(objectref)
    var_0009 = var_0008[1]
    var_000A = var_0008[2]
    for var_000D in ipairs(var_0007) do
        var_000E = unknown_0018H(var_000D)
        var_000F = var_000E[1]
        var_0010 = var_000E[2]
        var_0011 = var_000E[3]
        if var_000F <= var_0009 and var_0010 == var_000A and var_0011 == 1 then
            var_0006 = unknown_0025H(var_000D)
            if var_0006 then
                var_0006 = unknown_0026H({var_0011, var_0010, var_000F + 1})
            end
        elseif var_000F == var_0009 + 1 and var_0010 == var_000A and var_0011 == 1 then
            var_0006 = unknown_0025H(var_000D)
            if var_0006 then
                var_0006 = unknown_0026H({0, var_0010, var_000F})
            end
        end
    end
end