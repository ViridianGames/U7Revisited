--- Best guess: Manages the Ring of Regeneration, applying health regeneration to an NPC when equipped or used, with periodic checks and random item removal.
function object_ringregen_0298(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 5 then
        var_0000 = get_container(objectref)
        if var_0000 and is_npc(var_0000) then
            halt_scheduled(objectref)
            delayed_execute_usecode_array(objectref, {100, 298, 7765})
        else
            flash_mouse(0)
        end
    elseif eventid == 6 then
        halt_scheduled(objectref)
    elseif eventid == 2 then
        halt_scheduled(objectref)
        var_0000 = get_container(objectref)
        if var_0000 and is_npc(var_0000) then
            var_0002 = get_npc_property(0, var_0000)
            var_0003 = get_npc_property(3, var_0000)
            if var_0003 < var_0002 then
                var_0001 = set_npc_prop(1, 3, var_0000)
                if math.random(1, 100) == 1 then
                    remove_item(objectref)
                end
            end
            delayed_execute_usecode_array(objectref, {100, 298, 7765})
        end
    end
    return
end