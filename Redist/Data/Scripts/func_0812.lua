-- Function 0812: Play music and update state
function func_0812(eventid, itemref)
    local local0, local1, local2, local3

    local1 = check_sitting(-356)
    if not call_006DH() then
        local2 = get_item_position(eventid)
        local3 = call_0001H({15, -2, 17419, 17441, 7737}, eventid)
        _PlayMusic(0, 25)
        call_0089H(10, 2)
        call_0089H(26, local1)
    end
end