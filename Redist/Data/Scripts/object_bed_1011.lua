--- Best guess: Calls an external function (ID 0800H) for a vertical bed interaction, possibly for a rest or animation mechanic.
function object_bed_1011(eventid, objectref)
    if eventid == 1 then
        -- call [0000] (0800H, unmapped)
        utility_unknown_0768(objectref)
    end
    return
end