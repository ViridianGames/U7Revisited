require "U7LuaFuncs"
-- Manages ferry movement, toggling a flag and creating items to adjust positions based on the ferry's state.
function func_061C(eventid, itemref)
    local local0, local1

    set_schedule(itemref, 26)
    if not is_ferry_active(itemref) then -- Unmapped intrinsic
        if not get_flag(407) then
            local0 = {1591, 8021, 11, -2, 17419, 17441, 17458, 7724}
            set_flag(407, false)
        else
            local0 = {1591, 8021, 11, -2, 17419, 17441, 17462, 7724}
            set_flag(407, true)
        end
        local1 = add_item(itemref, local0)
    end
    return
end