-- Function 06A4: Sets Forge progression flag
function func_06A4(eventid, itemref)
    if eventid == 3 then
        set_flag(0x003C, true)
    end

    return
end

-- Helper functions
function set_flag(flag, value)
    -- Placeholder
end