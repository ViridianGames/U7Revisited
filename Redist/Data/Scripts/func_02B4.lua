-- Function 02B4: Play music track
function func_02B4(eventid, itemref)
    if eventid == 1 then
        _PlayMusic(itemref, 59)
    end
    return
end