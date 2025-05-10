--- Best guess: Calls an external function (ID 252) for an object interaction, possibly a clock or timer mechanism.
function func_02B7(eventid, objectref)
    if eventid == 1 then
        -- calle 00FCH, 252 (unmapped)
        unknown_00FCH(objectref)
    end
    return
end