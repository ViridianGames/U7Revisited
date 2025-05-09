--- Best guess: Compares a party member’s strength and mana, adjusting mana if strength exceeds it, likely for balance or quest purposes.
function func_08BF(eventid)
    local var_0001, var_0002, var_0003

    var_0001 = unknown_0910H(0, eventid)
    var_0002 = unknown_0910H(3, eventid)
    if var_0001 > var_0002 then
        var_0003 = var_0001 - var_0002
        unknown_0912H(var_0003, 3, eventid)
    end
    return
end