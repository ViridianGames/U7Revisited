require "U7LuaFuncs"
-- Function 00B2: Simple event handler calling function 0048
function func_00B2(eventid)
    -- Local variable (1 as per .localc)
    local local0

    -- Check if eventid == 1
    if eventid ~= 1 then
        return
    end

    -- Call function 0048 and store result
    local0 = callis_0048()

    return local0
end