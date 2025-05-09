--- Best guess: Calls an external function (ID 0800H) for an object interaction, possibly a custom event or trigger.
function func_02B8(eventid, itemref)
    if eventid == 1 then
        -- call [0000] (0800H, unmapped)
        unknown_0800H(itemref)
    end
    return
end