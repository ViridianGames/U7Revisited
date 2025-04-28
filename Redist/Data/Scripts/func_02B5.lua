require "U7LuaFuncs"
-- Function 02B5: Music and item iteration
function func_02B5(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid ~= 1 then
        return
    end

    _PlayMusic(itemref, 55)
    if _GetItemFrame(itemref) == 1 then
        calli_007E()
        local0 = callis_0030(534)
        while local0 do
            -- Note: Original has 'sloop' and 'db 2' for iteration, ignored
            local3 = local0 -- Current item
            calli_001D(3, local3)
            local0 = callis_0030(534) -- Re-check items
        end
    end

    return
end