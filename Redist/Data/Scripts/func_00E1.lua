-- Function 00E1: State-based item processing
function func_00E1(eventid, itemref)
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
        if call_081DH(7, 0, 0, 0, 392, itemref) == 0 then
            call_081EH(5, 3, 0, 0, 250, 1, 1, 246, itemref)
            calli_0086(itemref, 31)
        else
            call_0818H()
        end

    -- State == 0: Second modification path
    elseif local0 == 0 then
        if call_081DH(7, 0, 0, 1, 392, itemref) == 0 then
            call_081EH(7, 0, -3, 1, 250, 2, 0, 246, itemref)
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