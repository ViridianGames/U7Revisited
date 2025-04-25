-- Clears a flag, sets schedules for party members, and triggers an action on an item.
function func_0613(eventid, itemref)
    local local0, local1, local2, local3

    set_flag(57, false)
    local0 = get_party_members()
    for local1 in ipairs(local0) do
        local2 = local1
        local3 = local2
        set_schedule(local3, 31)
    end
    trigger_action(itemref) -- Unmapped intrinsic
    return
end