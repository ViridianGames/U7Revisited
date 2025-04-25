-- Function 00FB: Ship sail logic with deed checks and messages
function func_00FB(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    -- Check if eventid == 1 (original checks != 1, with db 2c if equal)
    if eventid == 1 then
        -- Note: Original has 'db 2c' here, possibly a debug artifact, ignored
        return
    end

    -- Call function 0081
    if callis_0081() ~= 0 then
        calli_007E()
    end

    -- Check itemref via function 0058
    if callis_0058(itemref) ~= 0 then
        return
    end

    -- Check item properties (199 and 251)
    local0 = callis_0035(0, 5, 199, itemref)
    local1 = callis_0035(0, 5, 251, itemref)

    -- Check if local1 is in itemref's array
    if not in_array(itemref, local1) then
        local1 = arra(itemref, local1)
    end

    -- Check condition with function 0088
    if not callis_0088(10, -356) then
        -- Get item quality
        local2 = _GetItemQuality(itemref)

        -- Check for scroll (797) with function 0028
        local3 = callis_0028(-359, local2, 797, -357)

        if not local3 then
            -- Check party size
            local party = _GetPartyMembers()
            if _ArraySize(party) == 1 then
                call_08FFH("@The deed for this vessel must first be purchased.@")
            else
                call_08FFH("@We must purchase the deed for this vessel before we sail her.@")
            end
            -- Note: Original has 'db 2c' here, ignored
        end

        -- Check sitting and blocking conditions
        if call_080DH() == 0 then
            call_0831H(itemref)
            return
        else
            local4 = call_08B3H(local0[1])
            calli_0089(20, itemref)
            return
        end
    else
        -- Set item attributes and play music
        calli_008A(20, itemref)
        call_0830H(0, local1)
        calli_008A(10, itemref)
        calli_008A(26, itemref)
        _PlayMusic(0, 255)
    end

    return
end

-- Helper functions (assumed to be defined elsewhere)
function in_array(itemref, value)
    -- Check if value is in itemref's array (simulating 'in' opcode)
    -- Implementation depends on itemref structure
    return false -- Placeholder
end

function arra(itemref, value)
    -- Add value to itemref's array (simulating 'arra' opcode)
    -- Implementation depends on itemref structure
    return value -- Placeholder
end