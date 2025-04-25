-- Function 0712: Handle item type 505
function func_0712(eventid, itemref)
    local local0, local1, local2, local3, local4

    if eventid == 3 then
        local0 = table.insert(call_0030H(505), call_0030H(970))
        if local0 then
            while local1 do
                local3 = local1
                call_08E6H(local3)
                local1 = get_next_item() -- sloop
            end
            delete_item(itemref)
        end
    end
end