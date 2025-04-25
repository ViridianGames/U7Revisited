-- Function 0881: Find item with specific frame
function func_0881(eventid, itemref)
    local local0, local1, local2, local3

    local0 = check_position(0, 0, 854, -356)
    while local3 do
        if _GetItemFrame(local3) >= 18 and _GetItemFrame(local3) <= 21 then
            set_return(local3)
        end
        local3 = get_next_item() -- sloop
    end
    set_return(0)
end