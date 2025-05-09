--- Best guess: Manages an item’s interaction, likely a switch or lever, toggling its state and applying effects.
function func_0313(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        unknown_007EH()
        var_0000 = -1
        var_0001 = -1
        var_0002 = -3
        unknown_0828H(7, itemref, 787, var_0002, var_0001, var_0000, itemref)
    elseif eventid == 7 then
        var_0003 = unknown_0827H(itemref, -356)
        var_0004 = unknown_0001H({17505, 17516, 8449, var_0003, 7769}, -356)
        unknown_0816H(itemref)
    elseif eventid == 2 then
        unknown_0816H(itemref)
    end
end