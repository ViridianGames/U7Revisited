--- Best guess: Animates an object with a sequence of frames, likely for a decorative or interactive effect.
function func_03E0(eventid, itemref)
    local var_0000, var_0001

    if eventid == 1 then
        -- calli 007E, 0 (unmapped)
        unknown_007EH()
        var_0000 = {0, 8006, 3, 8006, 4, 8006, 17, 8024, 4, 8006, 3, 8006, 0, 8006, 1, 8006, 2, 8006, 17, 8024, 2, 8006, 1, 8006, 0, 7750}
        var_0001 = unknown_0001H(var_0000, itemref)
    end
    return
end