require "U7LuaFuncs"
-- Function 02B1: Play music track
function func_02B1(eventid, itemref)
    if eventid == 1 then
        _PlayMusic(itemref, 57)
    end
    return
end