--- Best guess: Manages a crafting or transformation mechanic, checking item quality and positions, updating item states, and potentially generating new items based on random outcomes.
function utility_position_0269(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011

    if eventid ~= 2 then
        return
    end

    var_0000 = find_nearby(0, 10, 410, objectref)
    var_0001 = get_object_quality(var_0000)
    var_0002 = {915, 916, 914}
    var_0003 = var_0002[var_0001]
    if random2(20, 1) == 1 then
        var_0004 = get_object_position(objectref)
        var_0005 = create_new_object(var_0003)
        if var_0005 then
            set_item_flag(18, var_0005)
            get_object_frame(var_0005, 0)
            var_0006 = update_last_created({var_0004[2], var_0004[1] - 9})
        end
    end

    var_0007 = find_nearby(0, 10, 359, objectref)
    var_0008 = get_object_position(objectref)
    var_0009 = var_0008[1]
    var_000A = var_0008[2]
    for var_000D in ipairs(var_0007) do
        var_000E = get_object_position(var_000D)
        var_000F = var_000E[1]
        var_0010 = var_000E[2]
        var_0011 = var_000E[3]
        if var_000F <= var_0009 and var_0010 == var_000A and var_0011 == 1 then
            var_0006 = set_last_created(var_000D)
            if var_0006 then
                var_0006 = update_last_created({var_0011, var_0010, var_000F + 1})
            end
        elseif var_000F == var_0009 + 1 and var_0010 == var_000A and var_0011 == 1 then
            var_0006 = set_last_created(var_000D)
            if var_0006 then
                var_0006 = update_last_created({0, var_0010, var_000F})
            end
        end
    end
end