--- Best guess: Calls an external function (ID 252) for an object interaction, possibly a clock or timer mechanism.
function object_clock_0695(eventid, objectref)
    if eventid == 1 then
        -- calle 00FCH, 252 (unmapped)
        object_unknown_0252(objectref)
    end
    return
end