-- Function 0834: Raise portcullis
function func_0834(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17

    if not get_flag(87) then
        set_flag(87, true)
    end
    local0 = {check_position(0, 25, 276, -356), check_position(0, 25, 277, -356)} -- Tops
    local1 = {check_position(0, 25, 271, -356), check_position(0, 25, 272, -356)} -- Portcullises
    while local2 do
        local4 = local2
        local5 = call_0042H(local4)
        if local5 == 0 then
            local6 = call_0001H({3, -7, 7947, 0, 8006, 1543, 8021, 32, 7768}, local4)
            while local7 do
                local9 = local7
                local6 = call_0001H({3, 8006, 2, 8006, 1, 7750}, local9)
                local7 = get_next_item() -- sloop
            end
        elseif local5 == 1 then
            local6 = call_0001H({2, -7, 7947, 1, 8006, 1543, 8021, 32, 17496, 7715}, local4)
            while local10 do
                local11 = local10
                local6 = call_0001H({3, 8006, 2, 7750}, local11)
                local10 = get_next_item() -- sloop
            end
        elseif local5 == 2 then
            local6 = call_0001H({1, -7, 7947, 2, 8006, 1543, 8021, 32, 7768}, local4)
            while local12 do
                local13 = local12
                local6 = call_0001H({3, 7750}, local13)
                local12 = get_next_item() -- sloop
            end
        elseif local5 == 3 then
            local6 = call_0001H({2, -7, 7947, 3, 8006, 1545, 8021, 32, 7768}, local4)
            while local14 do
                local15 = local14
                local6 = call_0001H({3, 7750}, local15)
                local14 = get_next_item() -- sloop
            end
        elseif local5 == 4 then
            local6 = call_0001H({3, -7, 7947, 3, 8006, 1543, 8021, 32, 7768}, local4)
            while local16 do
                local17 = local16
                local6 = call_0001H({0, 8006, 1, 8006, 2, 7750}, local17)
                local16 = get_next_item() -- sloop
            end
        end
        local2 = get_next_item() -- sloop
    end
    set_return(true)
end