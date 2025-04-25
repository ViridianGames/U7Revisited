-- Function 0830: Sail manipulation
function func_0830(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        local2 = -4
        local3 = 88
        local4 = check_position(0, 25, 199, local1[1])
        local5 = call_0001H({0, 21, 7764}, local4)
    elseif eventid == 0 then
        local2 = 4
        local3 = 87
    end
    while local6 do
        local8 = local6
        local9 = call_006BH(local8)
        call_006CH(local8, local9 + local2)
        local6 = get_next_item() -- sloop
    end
    call_000FH(local3)
end