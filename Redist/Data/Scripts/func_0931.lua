-- Function 0931: Check condition with threshold
function func_0931(eventid, itemref)
    local local0

    local5 = check_condition(eventid, itemref, local2, local4)
    if local5 >= local3 then
        set_return(true)
    else
        set_return(false)
    end
end