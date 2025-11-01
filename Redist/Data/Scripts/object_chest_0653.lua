--- Best guess: Manages item pickup or interaction, checking container and player ownership, triggering specific actions (type 1581) if conditions are met.
function object_chest_0653(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        var_0000 = get_container(objectref)
        if var_0000 == get_npc_name(-356) then
            utility_spinningwheel_0301(7, objectref)
        elseif var_0000 then
            var_0001 = set_last_created(objectref)
            if var_0001 then
                var_0001 = give_last_created(-356)
                if not var_0001 then
                    var_0001 = give_last_created(var_0000)
                    flash_mouse(4)
                else
                    utility_spinningwheel_0301(7, objectref)
                end
            end
        else
            var_0002 = -1
            var_0003 = -1
            var_0004 = -1
            utility_position_0808(objectref, var_0002, var_0003, var_0004, 1581, objectref, 7)
        end
    end
    return
end