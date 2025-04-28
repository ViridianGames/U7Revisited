require "U7LuaFuncs"
-- Function 0713: Move and delete items
function func_0713(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    local0 = itemref
    if eventid == 2 then
        local1 = get_item_position(local0)
        move_object(-1, 0, 0, 0, local1[2], local1[1], 12)
        call_000FH(62)
        if _GetItemFrame(local0) == 3 then
            _SetItemFrame(2, local0)
        end
        local2 = check_position(176, 20, 912, local0)
        while local3 do
            local5 = local3
            move_object(-1, 0, 0, 0, local1[2], local1[1], 12)
            call_000FH(62)
            delete_item(local5)
            local3 = get_next_item() -- sloop
        end
    end
end