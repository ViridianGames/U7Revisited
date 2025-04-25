-- Function 0882: Ferry interaction
function func_0882(eventid, itemref)
    local local0, local1, local2, local3

    if not check_sitting(itemref) then
        local1 = check_position(16, 10, 961, itemref)
        if local1 then
            if call_080DH() and check_sitting(-356) then
                call_061CH(local1)
            else
                local2 = call_08B3H(itemref)
                call_008AH(10, -356)
                local3 = check_position(0, 25, 155, -356)
                if not local3 then
                    call_0089H(20, local3)
                end
            end
        end
    end
    return
end