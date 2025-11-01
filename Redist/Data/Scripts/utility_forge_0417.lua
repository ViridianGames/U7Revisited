--- Best guess: Modifies items in a dungeon forge, adjusting frames and positions for items with specific quality and frame values, then spawns additional items.
function utility_forge_0417(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    var_0000 = find_nearby(16, 10, 275, objectref)
    for i = 1, 5 do
        var_0004 = get_item_quality(var_0003)
        var_0005 = get_object_frame(var_0003)
        var_0006 = get_object_position(var_0003)
        if var_0005 == 6 then
            if var_0004 == 3 then
                var_0007 = create_new_object(623)
                set_object_frame(0, var_0007)
                var_0008 = update_last_created(var_0006)
                sprite_effect(1, 0, 0, 0, var_0006[2] - 2, var_0006[1] - 1, 13)
            elseif var_0004 == 7 then
                var_0009 = create_new_object(810)
                set_object_frame(0, var_0009)
                var_0008 = update_last_created(var_0006)
                sprite_effect(1, 0, 0, 0, var_0006[2] - 2, var_0006[1] - 1, 13)
            end
        end
    end
    var_000A = execute_usecode_array(1781, {8021, 2, 17447, 8033, 3, 17447, 8044, 4, 17447, 8045, 3, 17447, 7788}, objectref)
    play_sound_effect(68)
    return
end