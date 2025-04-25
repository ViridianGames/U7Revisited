-- Function 0814: Find items at specific location
function func_0814(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    local0 = {}
    local1 = check_position(0, 40, 414, -356)
    while local2 do
        local4 = local2
        local5 = get_item_position(local4)
        if local5[1] >= 2487 - 8 and local5[1] <= 2487 + 8 and local5[2] >= 1736 - 8 and local5[2] <= 1736 + 8 and (_GetItemFrame(local4) == 4 or _GetItemFrame(local4) == 5) then
            table.insert(local0, local4)
        end
        local2 = get_next_item() -- sloop
    end
    set_return(local0)
end