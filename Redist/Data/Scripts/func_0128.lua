--- Best guess: Manages a ring of invisibility, toggling invisibility status for the wearer based on equip/unequip events.
function func_0128(eventid, itemref)
    local var_0000

    if eventid == 5 or eventid == 6 then
        var_0000 = unknown_006EH(itemref)
        while var_0000 ~= 0 and not unknown_0031H(var_0000) do
            var_0000 = unknown_006EH(var_0000)
        end
        if var_0000 == 0 then
            unknown_006AH(0)
        end
        if eventid == 5 then
            unknown_0089H(0, var_0000)
        elseif eventid == 6 then
            unknown_008AH(0, var_0000)
        end
    end
end