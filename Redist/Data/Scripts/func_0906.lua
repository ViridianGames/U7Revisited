-- Function 0906: Check game condition
function func_0906(eventid, itemref)
    if call_0044H() == 3 then
        set_return(false)
    else
        set_return(true)
    end
end