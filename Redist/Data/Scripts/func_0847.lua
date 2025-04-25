-- Function 0847: Check item types
function func_0847(eventid, itemref)
    local local0 = eventid

    if local0 == 400 or local0 == 414 or local0 == 892 or local0 == 762 or local0 == 778 or local0 == 507 then
        set_return(1)
    else
        set_return(0)
    end
end