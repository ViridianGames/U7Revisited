--- Best guess: Updates an item’s type (P4) and frame (P3), moving it to a new position (P1, P2), returning true if successful.
function func_081D(P0, P1, P2, P3, P4, P5)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    func_081C(P3, P5)
    set_object_shape(P5, P4)
    var_0006 = func_0018(P5)
    var_0006[1] = var_0006[1] + P2
    var_0006[2] = var_0006[2] + P1
    if not func_0025(P5) then
        var_0007 = func_0026(var_0006)
    end
    return true
end