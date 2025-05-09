--- Best guess: Manages a helmet egg mechanic in the Courage region, checking for helms (IDs 383, 541) and altering portcullis (ID 936) or metal wall (ID 303) states based on quality.
function func_070D(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    var_0000 = unknown_0035H(0, 20, 936, itemref)
    var_0001 = unknown_0035H(0, 20, 303, itemref)
    var_0002 = _GetItemQuality(itemref)
    if not var_0002 then
        var_0003 = unknown_000EH(0, 383, itemref)
        var_0004 = unknown_000EH(0, 541, itemref)
        if var_0003 then
            set_flag(830, true)
            for var_0005 in ipairs(var_0001) do
                if _GetItemQuality(var_0007) == 12 then
                    var_0008 = unknown_0001H(var_0007, {936, 8021, 3, -1, 17419, 8016, 33, 8024, 4, 7750})
                end
            end
        else
            set_flag(830, false)
            for var_0009 in ipairs(var_0000) do
                if _GetItemQuality(var_0007) == 12 then
                    var_0008 = unknown_0001H(var_0007, {3, -1, 17419, 8014, 32, 8024, 303, 7765})
                end
            end
            if var_0004 then
                unknown_000FH(28)
            else
                unknown_000FH(28)
            end
        end
    else
        var_0004 = unknown_000EH(0, 541, itemref)
        var_0003 = unknown_000EH(0, 383, itemref)
        if var_0004 then
            set_flag(829, true)
            for var_000B in ipairs(var_0000) do
                if _GetItemQuality(var_0007) == 11 then
                    var_0008 = unknown_0001H(var_0007, {936, 8021, 3, -1, 17419, 8016, 33, 8024, 4, 7750})
                end
            end
        else
            set_flag(829, false)
            for var_000D in ipairs(var_0001) do
                if _GetItemQuality(var_0007) == 11 then
                    var_0008 = unknown_0001H(var_0007, {3, -1, 17419, 8014, 32, 8024, 303, 7765})
                end
            end
            if var_0003 then
                unknown_000FH(28)
            else
                unknown_000FH(28)
            end
        end
    end
end