-- Function 0944: Find outermost container
function func_0944(eventid, itemref)
    local local0

    local0 = get_container(itemref) -- callis 006E
    while local0 do
        if local0 == -356 then -- Avatar check
            set_return(local0)
            return
        end
        local0 = get_container(local0)
    end
    set_return(0)
end