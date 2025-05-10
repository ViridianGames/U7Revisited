--- Best guess: Handles weapon attacks, prompting the player to attack with it and managing item transformations or actions based on selections.
function func_030E(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        unknown_08FFH("@Perhaps thou shouldst attack with it.@", objectref)
    elseif eventid == 4 then
        var_0000 = unknown_0033H()
        var_0001 = {var_0000[2], var_0000[3], var_0000[4]}
        var_0002 = unknown_0024H(895)
        if var_0002 then
            unknown_0089H(18, var_0002)
            var_0003 = unknown_0026H(var_0001)
            if not var_0003 then
                var_0003 = unknown_0002H(var_0002, {100, 7715})
            end
        elseif var_0000[4] == 0 then
            var_0004 = unknown_0024H(224)
            if var_0004 then
                unknown_0089H(18, var_0004)
                var_0003 = unknown_0026H(var_0001)
            end
        end
        var_0005 = unknown_0035H(0, 2, 782, var_0000)
        if not var_0005 then
            unknown_0925H(var_0005)
        end
    end
    return
end