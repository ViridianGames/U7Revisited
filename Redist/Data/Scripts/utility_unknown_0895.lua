--- Best guess: Searches for nearby items with specific quality and frame attributes, processes them, and triggers explosions, likely for inventory or environmental effects.
function utility_unknown_0895(objectref)
    local var_0000, var_0001, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000C, var_000D, var_000E, var_000F, var_0012, var_0013, var_0014, var_0015

    var_0001 = find_nearbyobject_s(16, 15, 275, objectref) --- Guess: Finds nearby items
    for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
        var_0004 = var_0001[i]
        if var_0004 then
            var_0005 = get_object_quality(var_0004) --- Guess: Gets item quality
            var_0006 = get_object_frame(var_0004) --- Guess: Gets item frame
            var_0007 = get_position_data(var_0004) --- Guess: Gets position data
            if var_0005 == 10 and var_0006 == 6 then
                var_0008 = find_nearbyobject_s(0, 1, -1, var_0004) --- Guess: Finds nearby items
                var_0009 = 0
                if var_0008 then
                    for j = 1, 10 do --- Guess: Sloop loop for 10 iterations
                        var_000C = var_0008[j]
                        if var_000C then
                            var_000D = get_object_type(var_000C) --- Guess: Gets item type
                            if var_000D == 800 then
                                var_000E = get_position_data(var_000C) --- Guess: Gets position data
                                if var_000E[1] == var_0007[1] and var_000E[2] == var_0007[2] then
                                    var_0009 = var_000C
                                    var_000F = set_object_quality(var_0009, 100) --- Guess: Sets item quality
                                end
                            end
                        end
                    end
                    if not var_0009 then
                        var_0009 = create_object(800) --- Guess: Creates item
                        var_000F = set_object_quality(var_0009, 100) --- Guess: Sets item quality
                        set_object_frame(var_0009, 0) --- Guess: Sets item frame
                        var_000F = get_object_position(var_0007) --- Guess: Gets item position
                    end
                    for k = 1, 10 do --- Guess: Sloop loop for 10 iterations
                        var_000C = var_0008[k]
                        if var_000C then
                            var_000D = get_object_type(var_000C) --- Guess: Gets item type
                            var_00012 = get_position_data(var_000C) --- Guess: Gets position data
                            if var_00012[3] < 5 and var_000C ~= var_0009 then
                                if var_000D == 338 then
                                    var_00013 = get_object_quality(var_000C) --- Guess: Gets item quality
                                    var_00014 = get_object_frame(var_000C) --- Guess: Gets item frame
                                    var_000C = remove_item(var_000C) --- Guess: Unknown function
                                    var_000C = create_object(336) --- Guess: Creates item
                                    var_000F = set_object_quality(var_000C, var_00013) --- Guess: Sets item quality
                                    set_object_frame(var_000C, var_00014) --- Guess: Sets item frame
                                end
                                var_000F = move_object(var_000C) --- Guess: Moves item
                                var_000F = remove_object(var_0009) --- Guess: Removes item
                            end
                        end
                    end
                else
                    var_0009 = create_object(800) --- Guess: Creates item
                    var_000F = set_object_quality(var_0009, 100) --- Guess: Sets item quality
                    set_object_frame(var_0009, 0) --- Guess: Sets item frame
                    var_000F = get_object_position(var_0007) --- Guess: Gets item position
                end
                var_000E = get_position_data(var_0009) --- Guess: Gets position data
                create_explosion(-1, 0, 0, 0, var_000E[2] - 1, var_000E[1] - 1, 13) --- Guess: Creates explosion
                var_00015 = get_object_type(var_0000) --- Guess: Gets item type
                if var_00015 == 338 then
                    var_00013 = get_object_quality(var_0000) --- Guess: Gets item quality
                    var_00014 = get_object_frame(var_0000) --- Guess: Gets item frame
                    var_0000 = remove_item(var_0000) --- Guess: Unknown function
                    var_0000 = create_object(336) --- Guess: Creates item
                    var_000F = set_object_quality(var_0000, var_00013) --- Guess: Sets item quality
                    set_object_frame(var_0000, var_00014) --- Guess: Sets item frame
                end
                var_000F = move_object(var_0000) --- Guess: Moves item
                var_000F = remove_object(var_0009) --- Guess: Removes item
            end
        end
    end
end