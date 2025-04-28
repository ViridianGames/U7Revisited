require "U7LuaFuncs"
-- Function 02E9: Play music track
function func_02E9(eventid, itemref)
    if eventid == 1 then
        _PlayMusic(itemref, 58)
    end
    return
end