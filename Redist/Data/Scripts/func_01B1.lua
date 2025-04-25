-- Function 01B1: State-based item processing
function func_01B1(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    -- Check if eventid == 1 (original checks != 1, with db 2c if equal)
    if eventid == 1 then
        -- Note: Original has 'db 2c' here, possibly a debug artifact, ignored
        return
    end

    -- Get state via external function 081BH
    local0 = call_081BH(itemref)

    -- State == 1: First modification path
    if local0 == 1 then
        if call_081DH(1, 0, 3, 0, 432, itemref) == 0 then
            call_081EH(7, 0, 0, 0, 270, 2, 1, 376, itemref)
            calli_0086(itemref, 31)
        else
            call_0818H()
        end

    -- State == 0: Second modification path
    elseif local0 == 0 then
        if call_081DH(7, -3, 0, 1, 432, itemref) == 0 then
            call_081EH(7, 0, 0, 1, 270, 1, 0, 376, itemref)
            calli_0086(itemref, 30)
        else
            call_0818H()
        end

    -- State == 2: Call 0819H
    elseif local0 == 2 then
        call_0819H(itemref)

    -- State == 3: Call 081AH
    elseif local0 == 3 then
        call_081AH(itemref)
    end

    return
end