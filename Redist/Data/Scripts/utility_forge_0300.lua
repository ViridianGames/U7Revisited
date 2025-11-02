--- Best guess: Manages a forge routine, combining rock (ID 331) and blood (ID 912) items to craft golem bodies or other items, updating states and flags based on item quality (243 or 244).
function utility_forge_0300(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013

    var_0000 = objectref
    var_0001 = utility_unknown_1093(var_0000)
    var_0002 = find_nearby(0, 18, 331, {1736, 2487})
    for var_0003 in ipairs(var_0002) do
        var_0006 = find_nearby(176, 3, 912, var_0005)
        for var_0007 in ipairs(var_0006) do
            var_000A = get_object_frame(var_0009)
            var_000B = get_object_position(var_0009)
            remove_item(var_0009)
            var_000C = create_new_object(912)
            get_object_frame(var_000C, var_000A)
            var_000D = update_last_created(var_000B)
        end
    end

    var_000E = get_container_objects(4, 359, 797, var_0001)
    var_000F = execute_usecode_array(var_0000, {17453, 17452, 7715})
    if get_object_quality(var_000E) == 243 then
        utility_event_0998(var_0001)
        set_flag(753, false)
        set_flag(795, true)
    elseif get_object_quality(var_000E) == 244 then
        utility_event_0998(var_0001)
        set_flag(796, false)
        set_flag(754, false)
    end

    var_0002 = find_nearby_avatar(932)
    for var_0010 in ipairs(var_0002) do
        if get_object_frame(var_0012) == 2 or get_object_frame(var_0012) == 3 then
            set_camera(var_0012)
            fade_palette(0, 1, 12)
            var_0013 = execute_usecode_array(var_0012, {1599, 8021, 30, 7975, 1811, 8021, 1590, 17493, 7715})
        end
    end
end