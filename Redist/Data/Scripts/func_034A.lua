--- Best guess: Activates an item action (type 91) when its frame is 4, likely for a switch or trigger mechanism.
function func_034A(eventid, objectref)
    if unknown_0012H(objectref) == 4 then
        unknown_0813H(objectref, 2, 91)
    end
    return
end