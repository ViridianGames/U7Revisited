require "U7LuaFuncs"
-- Function 0909: Return gender-specific title
function func_0909(eventid, itemref)
    if _IsPlayerFemale() == 0 then
        set_return("milord")
    else
        set_return("milady")
    end
end