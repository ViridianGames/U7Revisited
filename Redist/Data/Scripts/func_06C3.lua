require "U7LuaFuncs"
-- Function 06C3: Manages Minoc murder scene
function func_06C3(eventid, itemref)
    -- Local variables (1 as per .localc)
    local local0

    if eventid ~= 3 then
        return
    end

    if not get_flag(0x0122) then
        set_flag(0x0122, true)
        callis_0066(5)
        abort()
    else
        local0 = callis_0065(5)
        if local0 >= 24 then
            call_080FH()
        end
        callis_006F(itemref)
    end

    return
end

-- Helper functions
function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end

function abort()
    -- Placeholder
end