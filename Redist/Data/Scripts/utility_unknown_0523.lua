--- Best guess: Manages a container mechanic, checking items within a container (ID -356), applying effects based on container state, and creating items (ID 1803).
function utility_unknown_0523(objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if not utility_unknown_1092(objectref) then
        var_0000 = get_object_position(objectref)
        var_0001 = false
        var_0002 = set_last_created(objectref)
        var_0003 = get_container_objects(-359, -359, -1, get_npc_name(-356))
        for var_0004 in ipairs(var_0003) do
            if var_0001 == false and not utility_unknown_1001(var_0006) then
                var_0002 = set_last_created(var_0006)
                var_0007 = get_object_position(get_npc_name(-356))
                var_0002 = update_last_created(var_0007)
            end
            if var_0001 == true and not utility_unknown_1002(var_0006) then
                var_0002 = set_last_created(var_0006)
                var_0007 = get_object_position(get_npc_name(-356))
                var_0002 = update_last_created(var_0007)
            end
            if var_0001 == 2 and get_container(var_0006) == get_npc_name(-356) then
                var_0002 = set_last_created(var_0006)
                var_0007 = get_object_position(get_npc_name(-356))
                var_0002 = update_last_created(var_0007)
            end
        end
        var_0001 = var_0001 + 1
        var_0002 = set_last_created(objectref)
    end
    var_0008 = execute_usecode_array(objectref, {1803, 17493, 17443, 7724})
end