--- Best guess: Displays a message describing fine cloth, suggesting it could be sold in Minoc or cut into bandages.
function func_0353(eventid, itemref)
    local var_0000

    if eventid == 1 then
        var_0000 = "@That appears to be fine cloth, no doubt it would fetch a fair price in Minoc. Or, perhapse, thou couldst cut it into bandages with shears.@"
        unknown_08FFH(var_0000)
    end
end