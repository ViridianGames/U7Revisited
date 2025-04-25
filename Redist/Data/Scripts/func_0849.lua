-- Function 0849: Check item types
function func_0849(eventid, itemref)
    local local0 = eventid

    if local0 == 519 or local0 == 354 or local0 == 528 or local0 == 337 or local0 == 317 or local0 == 299 then
        set_return(1)
    else
        set_return(0)
    end
end