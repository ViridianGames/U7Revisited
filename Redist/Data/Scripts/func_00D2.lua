-- Function 00D2: Item processing with quality checks and randomization
function func_00D2(eventid, itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    -- Check if eventid == 1
    if eventid ~= 1 then
        return
    end

    -- Get item quality and store in local0
    local0 = _GetItemQuality(itemref)

    -- Call function 003B and compare with local0
    if local0 == callis_003B() then
        -- Note: Original has 'db 2c' here, possibly a debug artifact, ignored
    end

    -- Call function 0015 and store result in local1
    local1 = callis_0015(itemref)

    -- Random check (original checks if Random2(0,1) > 1, which is impossible)
    -- Assuming Random2(min, max) returns integer in [min, max]
    if _Random2(0, 1) > 1 then
        -- This condition seems unreachable; possible bug in original
        return
    end

    -- Call function 0024 with 377 (0179H)
    local2 = callis_0024(377)

    -- If local2 is non-zero, proceed
    if local2 == 0 then
        return
    end

    -- Set item attributes
    calli_0089(18, local2)  -- Set attribute 18
    calli_008A(11, local2)  -- Set attribute 11
    _SetItemFrame(24, local2)  -- Set item frame to 24

    -- Get array from function 0018
    local3 = callis_0018(itemref)

    -- Modify array elements
    local4 = 1 - _Random2(0, 1)  -- Array index 1
    local5 = 1 - _Random2(0, 1)  -- Array index 2
    local6 = 2                    -- Array index 3 (1 + 1)

    -- Create new array and pass to function 0026
    local1 = callis_0026({local4, local5, local6})

    return local1
end