--- Best guess: Compares a party member's strength and mana, adjusting mana if strength exceeds it, likely for balance or quest purposes.
function utility_unknown_0959(eventid)
    local var_0001, var_0002, var_0003

    var_0001 = utility_unknown_1040(0, eventid)
    var_0002 = utility_unknown_1040(3, eventid)
    if var_0001 > var_0002 then
        var_0003 = var_0001 - var_0002
        utility_unknown_1042(var_0003, 3, eventid)
    end
    return
end