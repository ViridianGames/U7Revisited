-- Function 03C8: Frame-based actions with positioning
function func_03C8(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 1 then
        local0 = _GetItemFrame(itemref)
        if local0 == 0 then
            call_0805H(itemref)
        elseif local0 == 1 then
            call_0807H(itemref)
        elseif local0 == 2 then
            call_0803H(itemref)
        end
    elseif eventid == 2 then
        local1 = callis_0018(itemref)
        callis_0053(-1, 0, 0, 0, local1[2] - 3, local1[1] - 3, 7)
    end

    return
end