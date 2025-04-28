require "U7LuaFuncs"
-- Function 028C: Manages barge interaction
function func_028C(itemref)
    if eventid() == 1 then
        call_0809H(itemref)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end