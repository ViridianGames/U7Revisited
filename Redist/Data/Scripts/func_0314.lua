--- Best guess: Manages a lever or switch, toggling its frame and applying effects to nearby items (e.g., IDs 870, 515) if quality matches.
function func_0314(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid == 1 then
        unknown_007EH()
        var_0000 = -1
        var_0001 = -1
        var_0002 = -3
        unknown_0828H(7, itemref, 788, var_0002, var_0001, var_0000, itemref)
    elseif eventid == 7 or eventid == 2 then
        if eventid ~= 2 then
            var_0003 = unknown_0827H(itemref, -356)
            var_0004 = unknown_0001H({17505, 17511, 8449, var_0003, 7769}, -356)
        end
        var_0005 = get_object_frame(itemref)
        if var_0005 % 2 == 0 then
            get_object_frame(var_0005 + 1, itemref)
        else
            get_object_frame(var_0005 - 1, itemref)
        end
        unknown_0086H(itemref, 28)
        var_0006 = _get_object_quality(itemref)
        var_0007 = unknown_0035H(0, 15, 870, itemref)
        var_0008 = unknown_0035H(0, 15, 515, itemref)
        var_0007 = table.concat({var_0007, var_0008})
        var_0008 = {}
        for var_0009 in ipairs(var_0007) do
            if _get_object_quality(var_000B) == var_0006 then
                table.insert(var_0008, var_000B)
            end
        end
        var_0004 = unknown_080EH(var_0008)
        unknown_0836H(-359, itemref)
    end
end