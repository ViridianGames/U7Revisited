--- Best guess: Adjusts item positions based on type (sextant, map, or sextant part), moving them to specific coordinates for quest or puzzle purposes.
function func_08EB(var_0000, var_0001, var_0002)
    local var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018

    var_0003 = 4
    var_0004 = 0
    var_0005 = unknown_0018H(itemref)
    var_0006 = var_0005
    if var_0001 == 154 then
        var_0007 = unknown_0035H(0, 0, -1, itemref)
        for _, var_0010 in ipairs(var_0007) do
            var_0011 = unknown_0018H(var_0010)
            if var_0011[3] < 5 then
                var_0012 = unknown_0025H(var_0010)
                var_0013 = unknown_0010H(3, 1)
                if var_0013 == 1 then
                    var_0011[1] = var_0011[1] - 1
                elseif var_0013 == 2 then
                    var_0011[2] = var_0011[2] - 1
                elseif var_0013 == 3 then
                    var_0011[1] = var_0011[1] - 1
                    var_0011[2] = var_0011[2] - 1
                end
                var_0012 = unknown_0026H(var_0011)
            end
        end
    elseif var_0001 == 1015 then
        var_0007 = unknown_0035H(0, 1, -1, itemref)
        for _, var_0010 in ipairs(var_0007) do
            var_0011 = unknown_0018H(var_0010)
            if var_0011[3] < 5 then
                var_0012 = unknown_0025H(var_0010)
                if var_0011[1] == var_0005[1] and var_0011[2] == var_0005[2] then
                    var_0011[1] = var_0011[1] - 2
                    var_0011[2] = var_0011[2] - 2
                elseif var_0011[1] <= var_0005[1] and var_0011[2] <= var_0005[2] then
                    var_0011[1] = var_0011[1] - 1
                    var_0011[2] = var_0011[2] - 1
                end
                var_0012 = unknown_0026H(var_0011)
            end
        end
    elseif var_0001 == 504 then
        var_0003 = 6
        var_0004 = 2
        var_0007 = unknown_0035H(0, 3, -1, itemref)
        for _, var_0010 in ipairs(var_0007) do
            var_0011 = unknown_0018H(var_0010)
            if var_0011[3] < 5 and (unknown_0011H(var_0010) ~= 331 and unknown_0011H(var_0010) ~= 224) then
                if var_0011[1] == var_0005[1] and var_0011[2] == var_0005[2] then
                    var_0018 = var_0003 - unknown_0019H(itemref, var_0010)
                    var_0011[1] = var_0011[1] - var_0018
                    var_0011[2] = var_0011[2] - var_0018
                elseif var_0011[1] <= var_0005[1] and var_0011[2] <= var_0005[2] then
                    var_0011[1] = var_0011[1] - 1
                    var_0011[2] = var_0011[2] - 1
                end
                var_0012 = unknown_0026H(var_0011)
            end
        end
    end
    if not unknown_0085H(var_0000, var_0001, var_0005) then
        var_0004 = var_0004 + 1
        var_0007 = unknown_0035H(0, var_0004, -1, var_0006)
        for _, var_0010 in ipairs(var_0007) do
            var_0011 = unknown_0018H(var_0010)
            if var_0011[1] >= var_0005[1] and var_0011[2] >= var_0005[2] and var_0011[3] < 5 then
                var_0012 = unknown_0025H(var_0010)
                if var_0011[1] == var_0005[1] or var_0011[2] == var_0005[2] then
                    if var_0011[1] == var_0005[1] then
                        var_0011[1] = var_0011[1] + 1
                    end
                    if var_0011[2] == var_0005[2] then
                        var_0011[2] = var_0011[2] + 1
                    end
                else
                    var_0011[1] = var_0011[1] + 1
                    var_0011[2] = var_0011[2] + 1
                end
                var_0012 = unknown_0026H(var_0011)
            end
        end
        if var_0004 == var_0003 then
            return
        end
    end
    return
end