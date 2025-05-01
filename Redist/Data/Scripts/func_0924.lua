-- Function 0924: Check and manage item transaction
function func_0924(eventid, itemref)
    local local0, local1, local2, local3

    local2 = check_condition(-359, -359, 644, -357)
    add_dialogue(itemref, "\"To be agreeable?\"")
    if not get_answer() then
        local3 = 0
    else
        if local2 >= eventid then
            local4 = has_item(-359, -359, 761, -357)
            if local4 then
                if check_inventory_space(local4, 0, itemref) then
                    local3 = 1
                    remove_item(true, -359, -359, 644, eventid)
                else
                    local3 = 4
                end
            else
                local3 = 2
            end
        else
            local3 = 3
        end
    end
    set_return(local3)
end