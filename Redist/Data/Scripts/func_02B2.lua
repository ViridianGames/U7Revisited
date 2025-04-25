-- Function 02B2: Play music track
function func_02B2(eventid, itemref)
    if eventid == 1 then
        _PlayMusic(itemref, 56)
    end
    return
end