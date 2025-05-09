--- Best guess: Activates an item action (type 91) when its frame is 4, likely for a switch or trigger mechanism.
function func_034A(eventid, itemref)
    if unknown_0012H(itemref) == 4 then
        unknown_0813H(itemref, 2, 91)
    end
    return
end