--- Best guess: Manages the "Vas An Zu" spell, awakening sleeping targets (ID -1) within a radius, with a fallback effect if the spell fails.
function func_064F(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid ~= 1 then
        if eventid == 2 then
            unknown_005CH(itemref)
            unknown_008AH(itemref, 1)
        end
        return
    end

    var_0000 = unknown_0018H(itemref)
    unknown_005CH(itemref)
    bark(itemref, "@Vas An Zu@")
    if not unknown_0906H() then
        unknown_0053H(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 7)
        var_0001 = unknown_0001H(itemref, {17511, 8037, 68, 7768})
        var_0002 = 25
        var_0003 = unknown_0035H(4, var_0002, -1, itemref)
        for var_0004 in ipairs(var_0003) do
            var_0001 = unknown_0001H(var_0006, {1615, 17493, 7715})
        end
    else
        var_0001 = unknown_0001H(itemref, {1542, 17493, 17511, 7781})
    end
end