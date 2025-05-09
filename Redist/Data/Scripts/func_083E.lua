--- Best guess: Manages a winch mechanic, handling events to raise/lower objects (via 0828H) and checking for blockers (via 080EH), with quality-based filtering.
function func_083E(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if P0 == 1 then
        if unknown_0079H(P1) then
            abort()
        end
        unknown_0828H(7, P1, 1585, -1, {-2, -2}, P1)
    elseif P0 == 2 then
        var_0002 = _GetItemQuality(itemref)
        var_0003 = unknown_0035H(0, 15, 870, itemref)
        var_0004 = unknown_0035H(0, 15, 515, itemref)
        table.insert(var_0003, var_0004)
        var_0004 = {}
        for var_0005 in ipairs(var_0003) do
            if _GetItemQuality(var_0007) == var_0002 then
                table.insert(var_0004, var_0007)
            end
        end
        if unknown_080EH(0, var_0004) then
            var_0008 = unknown_0001H(itemref, {4, -1, 17419, 8014, 1, 7750})
        elseif not get_flag(61) then
            return false
        else
            unknown_0834H()
        end
    end
end