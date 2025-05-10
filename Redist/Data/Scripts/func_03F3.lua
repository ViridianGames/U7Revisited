--- Best guess: Calls an external function (ID 0800H) for a vertical bed interaction, possibly for a rest or animation mechanic.
function func_03F3(eventid, objectref)
    if eventid == 1 then
        -- call [0000] (0800H, unmapped)
        unknown_0800H(objectref)
    end
    return
end