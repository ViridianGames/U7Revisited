-- Function 0805: Initialize cart
function func_0805(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if not get_flag(4) then
        _SetItemType(981, eventid)
        local1 = {1120, 535, 0}
        call_003EH(local1, eventid)
        local1[2] = local1[2] + 2
        call_003EH(local1, -356)
        call_0808H()
        local2 = check_position(16, 10, 776, -356)
        while local3 do
            local5 = local3
            delete_item(local5)
            local3 = get_next_item() -- sloop
        end
        local6 = call_0002H(8, 1563, {17493, 7715}, -356)
        set_flag(4, true)
    end
end