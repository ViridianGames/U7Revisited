--- Best guess: Manages the Orb of the Moons, creating a moongate for teleportation if conditions (e.g., flag 57) are met, with specific positioning logic.
function object_orb_0785(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010

    if eventid == 1 then
        if get_flag(4) then
            utility_unknown_1022({"@It work before.@", "@How odd!@"})
        elseif not get_flag(57) and not utility_unknown_1086() then
            var_0000 = object_select_modal()
            var_0001 = utility_position_0802(var_0000)
            var_0002 = find_direction(var_0001, -356)
            if var_0002 == 0 or var_0002 == 4 then
                var_0003 = 1
                var_0004 = 779
            else
                var_0003 = 2
                var_0004 = 157
            end
            var_0001[var_0003] = var_0001[var_0003] + 2
            if not is_not_blocked(0, var_0004, var_0001) then
                for var_0006 in ipairs({1, 2, 3}) do
                    if is_not_blocked(0, var_0004, var_0001) then
                        break
                    end
                    var_0001[3] = var_0001[3] + 1
                end
                if not is_not_blocked(0, var_0004, var_0001) then
                    flash_mouse(0)
                end
            end
            close_gumps()
            var_0009 = create_new_object(var_0004)
            if not var_0009 then
                close_gumps()
                var_000A = update_last_created(var_0001)
                var_0001[var_0003] = var_0001[var_0003] - 2
                play_music(51, 33)
                set_item_flag(18, var_0009)
                set_object_quality(var_0002, var_0009)
                var_000A = execute_usecode_array(var_0009, {7981, 3, -1, 17419, 8016, 4, 8006, 5, -7, 7947, 5, 5, -1, 17420, 8014, 4, 8006, 10, -1, 17419, 8014, 0, 7750})
                var_000B = 5 - get_distance(-356, var_0009)
                var_000C = {8496 + var_0002, 7769}
                if var_000B > 0 then
                    table.insert(var_000C, var_000B)
                    table.insert(var_000C, 7719)
                end
                var_000A = execute_usecode_array(var_000C, -356)
                var_000D = get_object_position(-356)
                if var_000D[var_0003] < var_0001[var_0003] then
                    var_000E = 1
                else
                    var_000E = -1
                end
                var_0001[var_0003] = var_0001[var_0003] + var_000E
                var_000A = path_run_usecode(7, var_0009, 785, var_0001)
                if not var_000A then
                    set_path_failure(8, var_0009, 785)
                    var_000F = get_container(objectref)
                    var_0010 = get_party_members()
                    while var_000F and #var_0010 > 1 do
                        if not table.contains(var_0010, var_000F) then
                            var_000F = get_container(var_000F)
                        else
                            break
                        end
                    end
                    if not var_000F then
                        remove_item(objectref)
                        var_000A = add_party_items(false, 0, 0, 785, 1)
                    end
                else
                    utility_event_0801(var_0009)
                end
            else
                utility_event_0801(var_0009)
            end
        end
    elseif eventid == 8 then
        if not utility_unknown_0806(objectref) then
            utility_event_0801(objectref)
            utility_unknown_1022({"@Let thyself enter.@", "@No, Avatar.@"})
        end
    elseif eventid == 7 then
        if not utility_unknown_0806(objectref) then
            utility_event_0801(objectref)
            utility_unknown_0804(objectref)
        end
    end
end