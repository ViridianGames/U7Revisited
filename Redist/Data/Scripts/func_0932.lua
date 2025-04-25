-- Function 0932: Negate itemref if negative
function func_0932(eventid, itemref)
    if itemref < 0 then
        itemref = itemref * -1
    end
    set_return(itemref)
end