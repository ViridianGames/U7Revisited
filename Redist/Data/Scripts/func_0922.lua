-- Function 0922: Check training eligibility and gold
function func_0922(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    local4 = false
    local5 = call_0910H(7, itemref)
    local6 = check_condition(-359, -359, 644, -357)
    if local6 <= local2 then
        set_return(1)
    end
    if local5 >= eventid then
        set_return(0)
    end
    while local3 do
        local9 = local3
        local10 = call_0910H(local9, itemref)
        if local10 < 30 then
            local4 = true
        end
        local3 = get_next_party_member() -- sloop
    end
    if local4 == false then
        set_return(2)
    end
    set_return(3)
end