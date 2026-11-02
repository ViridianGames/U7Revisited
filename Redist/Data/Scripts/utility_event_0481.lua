--- Orrery (BG 0x0481): count SET plot flags among nine bits → state 0..9 for set_orrery.
--- Matches retail usecode (B0): start=0 spread, all set=9 cluster. eventid 3 only.
function utility_event_0481(eventid, objectref)
    local var_0000, var_0001

    if eventid == 3 then
        if objectref == 0 then
            var_0000 = {2892, 1420}
        else
            var_0000 = get_object_position(objectref)
        end
        var_0001 = 0
        if get_flag(493) then var_0001 = var_0001 + 1 end
        if get_flag(308) then var_0001 = var_0001 + 1 end
        if get_flag(482) then var_0001 = var_0001 + 1 end
        if get_flag(599) then var_0001 = var_0001 + 1 end
        if get_flag(481) then var_0001 = var_0001 + 1 end
        if get_flag(3) then var_0001 = var_0001 + 1 end
        if get_flag(301) then var_0001 = var_0001 + 1 end
        if get_flag(4) then var_0001 = var_0001 + 1 end
        if get_flag(5) then var_0001 = var_0001 + 1 end
        set_orrery(var_0001, var_0000)
    end
    return
end