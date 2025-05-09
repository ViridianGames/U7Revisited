--- Best guess: Manages gangplank positioning for item types 781 or 150, adjusting position arrays using helper functions (082BH, 082AH).
function func_082D(P0, P1, P2)
    local var_0000, var_0001, var_0002

    if P0 == 781 then
        P1 = unknown_082BH(3, P1)
        P2 = unknown_082AH(3, P1, P2)
    elseif P0 == 150 then
        P2 = unknown_082AH(3, P1, P2)
    end
    return P2
end