--- Updates door frame and adjusts position to simulate hinge rotation
--- P0 = unused
--- P1 = Z offset
--- P2 = X offset
--- P3 = frame adjustment
--- P4 = new shape
--- P5 = object ID

-- Track original positions for each door to toggle between original and offset
local doorOriginalPositions = {}

function utility_position_0797(P0, P1, P2, P3, P4, P5)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    utility_unknown_0796(P3, P5)
    set_object_shape(P5, P4)

    -- Position adjustment to keep door rotating around hinge
    if true then -- TODO no clue what this was doing? the intrinsic func makes no sense not func_0037(P5) then
        var_0006 = get_object_position(P5)  -- Get current position {x, y, z}

        -- If we haven't seen this door before, save its original position
        if not doorOriginalPositions[P5] then
            doorOriginalPositions[P5] = {var_0006[1], var_0006[2], var_0006[3]}
        end

        local origPos = doorOriginalPositions[P5]

        -- Check if door is currently at original position
        local atOriginal = (math.abs(var_0006[1] - origPos[1]) < 0.01 and
                           math.abs(var_0006[3] - origPos[3]) < 0.01)

        local newX, newY, newZ
        if atOriginal then
            -- Door is closed, move it to open position (inverted offsets)
            newX = origPos[1] - P2
            newY = origPos[2]
            newZ = origPos[3] - P1
        else
            -- Door is open, move it back to original position
            newX = origPos[1]
            newY = origPos[2]
            newZ = origPos[3]
        end

        set_object_position(P5, newX, newY, newZ)
    end

    return true
end