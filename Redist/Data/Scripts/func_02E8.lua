--- Best guess: Executes an external function with large parameters, possibly for a rare event or system check.
function func_02E8(eventid, itemref)
    if eventid == 1 then
        -- calli 0050, 2 (unmapped)
        unknown_0050H(1000, 10000)
    end
    return
end