-- Function 02B3: Play music track
function func_02B3(eventid, itemref)
    if eventid == 1 then
        _PlayMusic(itemref, 58)
    end
    return
end