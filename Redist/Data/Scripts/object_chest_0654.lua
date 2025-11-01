--- Best guess: Similar to func_028D, manages item pickup or interaction, checking container and player ownership, triggering different actions (type 1582).
function object_chest_0654(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        var_0000 = get_container(objectref)
        if var_0000 == get_npc_name(-356) then
            utility_loom_0302(7, objectref)
        elseif var_0000 then
            var_0001 = set_last_created(objectref)
            if var_0001 then
                var_0001 = give_last_created(-356)
                if not var_0001 then
                    var_0001 = give_last_created(var_0000)
                    flash_mouse(4)
                else
                    utility_loom_0302(7, objectref)
                end
            end
        else
            var_0002 = -1
            var_0003 = -1
            var_0004 = -1
            utility_position_0808(objectref, var_0002, var_0003, var_0004, 1582, objectref, 7)
        end
    end
    return
end