-- Function 0844: Find item with frame 12
function func_0844(eventid, itemref)
    local local0, local1, local2, local3, local4

    local0 = itemref
    while local0 do
        local3 = local0
        local4 = _GetItemFrame(local3)
        if local4 == 12 then
            set_return(local3)
            return
        end
        local0 = get_next_item() -- sloop
    end
    set_return(0)
end