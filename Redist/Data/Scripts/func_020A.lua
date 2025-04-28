require "U7LuaFuncs"
-- Function 020A: Manages locked chest interaction
function func_020A(itemref)
    if eventid() == 1 then
        callis_0040("Locked", itemref)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end