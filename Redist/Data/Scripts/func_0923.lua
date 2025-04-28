require "U7LuaFuncs"
-- Function 0923: Check and manage spellbook transaction
function func_0923(eventid, itemref)
    local local0, local1, local2, local3

    local2 = check_condition(-359, -359, 644, -357)
    say(itemref, "\" Agreeable?\"")
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