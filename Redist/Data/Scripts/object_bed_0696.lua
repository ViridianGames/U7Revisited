--- Best guess: Calls an external function (ID 0800H) for an object interaction, possibly a custom event or trigger.
function object_bed_0696(eventid, objectref)
    if eventid == 1 then
        -- call [0000] (0800H, unmapped)
        utility_unknown_0768(objectref)
    end
    return
end