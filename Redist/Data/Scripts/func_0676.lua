require "U7LuaFuncs"
-- Casts the "In Zu Grav" spell, inducing sleep with an electrical effect on a selected target.
function func_0676(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        local0 = item_select_modal() -- Unmapped intrinsic
        local1 = external_092DH(local0) -- Unmapped intrinsic
        item_say("@In Zu Grav@", itemref)
        if not external_0906H(local1) then -- Unmapped intrinsic
            local2 = add_item(itemref, {17511, 17510, 8549, local1, 8025, 65, 7768})
            local3 = local0[2] + 1
            local4 = local0[3] + 1
            local5 = local0[4]
            local6 = {local5, local4, local3}
            local7 = get_item_by_type(902) -- Unmapped intrinsic
            if local7 then
                set_flag(local7, 18, true)
                set_item_data(local6)
            end
        else
            local2 = add_item(itemref, {1542, 17493, 17511, 17510, 8549, local1, 7769})
        end
    end
    return
end