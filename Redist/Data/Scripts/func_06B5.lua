--- Best guess: Manages an egg in a blacksmith’s house, checking nearby items (types 270, 376) and triggering external functions based on their properties.
function func_06B5(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 3 then
        var_0000 = unknown_0035H(0, 40, 270, itemref)
        var_0000 = unknown_0035H(0, 40, 376, itemref)[var_0000]
        var_0001 = {}
        for i = 1, #var_0000 do
            var_0001 = unknown_0019H(var_0001, var_0000[i], itemref)
        end
        var_0000 = unknown_093DH(var_0001, var_0000)
        var_0005 = 1
        while var_0005 <= #var_0000 do
            var_0004 = var_0000[var_0005]
            if var_0004 then
                if unknown_081BH(var_0004) == 2 then
                    var_0005 = var_0005 + 1
                else
                    var_0006 = unknown_0011H(var_0004)
                    if var_0006 == 270 then
                        unknown_010EH(var_0004)
                    elseif var_0006 == 376 then
                        unknown_0178H(var_0004)
                    end
                    break
                end
            else
                break
            end
        end
    end
    return
end