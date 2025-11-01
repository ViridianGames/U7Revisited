--- Best guess: Manages a ferry mechanic, toggling between two destinations (likely ports) using flag 407 to determine the route, updating the ferry's state with predefined coordinates.
function utility_unknown_0284(eventid, objectref)
    local var_0000, var_0001

    set_item_flag(26, objectref)
    if not in_usecode(objectref) then
        if not get_flag(407) then
            var_0000 = {1591, 8021, 11, -2, 17419, 17441, 17458, 7724}
            set_flag(407, false)
        else
            var_0000 = {1591, 8021, 11, -2, 17419, 17441, 17462, 7724}
            set_flag(407, true)
        end
        var_0001 = execute_usecode_array(objectref, var_0000)
    end
end