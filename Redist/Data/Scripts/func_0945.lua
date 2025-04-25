-- Function 0945: Find container chain
function func_0945(eventid, itemref)
    local local0, local1

    local0 = get_container(itemref) -- callis 006E
    while local0 do
        local1 = local0
        local0 = get_container(local0)
    end
    set_return(local1)
end