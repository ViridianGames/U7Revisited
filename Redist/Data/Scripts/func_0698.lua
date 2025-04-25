-- Function 0698: Handle item type 521 and 500
function func_0698(eventid, itemref)
    local local0, local1, local2, local3, local4

    local0 = get_item_position(itemref)
    local1 = check_position(4, 1, 521, itemref)
    local2 = check_position(4, 1, 500, itemref)
    if local1 then
        move_object(-1, 0, 0, 0, local0[2], local0[1], 13)
        call_000FH(67)
        delete_item(local1)
        _SetItemFrame(28, itemref)
        local3 = call_0001H(1686, {8021, 3, 17447, 8033, 4, 17447, 8044, 5, 17447, 7789}, itemref)
    end
    if local2 then
        move_object(-1, 0, 0, 0, local0[2], local0[1], 17)
        move_object(-1, 0, 0, 0, local0[2], local0[1], 7)
        call_000FH(62)
        delete_item(local2)
        _SetItemFrame(30, itemref)
        local3 = call_0001H(1686, {8021, 3, 17447, 8033, 4, 17447, 8048, 5, 17447, 7791}, itemref)
    end
end