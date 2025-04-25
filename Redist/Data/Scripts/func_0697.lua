-- Function 0697: Erethian's transformation effects
function func_0697(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15

    local0 = get_item_position(itemref)
    if not get_flag(3) then
        if not get_flag(811) then
            set_flag(811, true)
            move_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 13)
            move_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 7)
            call_000FH(67)
            _SetItemFrame(4, itemref)
            local1 = call_0024H(274)
            _SetItemFrame(28, local1)
            local2 = call_0026H(local0)
            local3 = call_0001H(1686, {8021, 16, 7719}, itemref)
            local4 = call_0001H({8035, 3, 17447, 8044, 4, 17447, 8045, 4, 7769}, local1)
        else
            if not get_flag(812) then
                set_flag(812, true)
                move_object(-1, 0, 0, 0, local0[2], local0[1] - 1, 17)
                move_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 4)
                call_000FH(9)
                delete_item(check_condition(1, 274, itemref))
                local5 = call_0024H(504)
                _SetItemFrame(19, local5)
                local2 = call_0026H(local0)
                local6 = check_condition(1, 154, local5)
                local3 = call_0001H(1686, {8021, 14, 7719}, local6)
                local7 = call_0001H({8041, 2, 17447, 8042, 3, 17447, 8040, 4, 7975, 4, 7769}, local5)
            else
                move_object(-1, 0, 0, 0, local0[2], local0[1], 17)
                move_object(-1, 0, 0, 0, local0[2], local0[1], 7)
                call_000FH(8)
                delete_item(check_condition(1, 154, itemref))
                _SetItemFrame(28, check_condition(1, 154, itemref))
                local2 = call_0026H(local0)
                local3 = call_0001H({8033, 4, 17447, 8044, 5, 17447, 7789}, local6)
                call_001DH(29, local6)
                local8 = call_0881H()
                local9 = call_0002H(13, {17453, 7724}, local8)
                local10 = call_0001H(1693, {8021, 11, 7719}, call_001BH(-356))
            end
        end
    else
        set_flag(812, true)
        move_object(-1, 0, 0, 0, local0[2], local0[1], 17)
        move_object(-1, 0, 0, 0, local0[2], local0[1], 4)
        call_000FH(62)
        _SetItemFrame(4, itemref)
        local11 = call_0024H(500)
        _SetItemFrame(23, local11)
        local2 = call_0026H(local0)
        local12 = call_0001H(1688, {7463, "@Squeak!@", 8018, 11, 7719}, itemref)
        local13 = call_0001H({8036, 2, 17447, 8034, 1, 17447, 8036, 1, 17447, 8035, 2, 17447, 8036, 1, 17447, 8035, 1, 17447, 8034, 4, 7975, 4, 7769}, local11)
    end
end