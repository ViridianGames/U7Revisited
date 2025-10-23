--- Best guess: Updates an item's type (P4) and frame (P3), moving it to a new position (P1, P2), returning true if successful.
function func_081D(P0, P1, P2, P3, P4, P5)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    func_081C(P3, P5)
    set_object_shape(P5, P4)

    -- Position adjustment to keep door rotating around hinge
    var_0006 = func_0018(P5)  -- Get current position {x, y, z}
    local newX = var_0006[1] + P2  -- Adjust X by P2
    local newY = var_0006[2]        -- Keep Y unchanged
    local newZ = var_0006[3] + P1  -- Adjust Z by P1
    if not func_0025(P5) then
        -- Set the new position
        set_object_position(P5, newX, newY, newZ)
    end

    return true
end