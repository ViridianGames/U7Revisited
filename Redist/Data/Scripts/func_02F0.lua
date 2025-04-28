require "U7LuaFuncs"
-- Function 02F0: Music box state and playback
function func_02F0(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    if eventid ~= 1 then
        return
    end

    local0 = _GetItemFrame(itemref)
    if local0 == 0 then
        _SetItemFrame(1, itemref)
        _PlayMusic(itemref, 41)
        if call_08F7H(-144) then
            set_flag(0x01A7, true)
            calle_0490H(callis_001B(-144))
        end
    else
        _SetItemFrame(0, itemref)
        _PlayMusic(itemref, 255)
    end

    return
end

-- Helper function
function set_flag(flag, value)
    -- Placeholder
end