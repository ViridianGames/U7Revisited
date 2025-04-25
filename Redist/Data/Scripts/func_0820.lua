-- Function 0820: Open door
function func_0820(eventid, itemref)
    local local0, local1

    local1 = call_081BH(eventid)
    if local1 == 1 then
        if not call_081DH(7, 0, 0, 0, 828, eventid) then
            call_0086H(itemref, 31)
        else
            call_0818H()
            set_return(false)
        end
    elseif local1 == 0 then
        if not call_081DH(7, 0, 0, 1, 828, eventid) then
            call_0086H(itemref, 30)
        else
            call_0818H()
            set_return(false)
        end
    end
    set_return(true)
end