--- Best guess: Searches party members’ containers for a specific item, updating positions if found.
function func_0926(eventid, itemref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    var_0001 = false
    var_0002 = get_item_type(arg1) --- Guess: Gets item type
    var_0003 = get_item_frame(arg1) --- Guess: Gets item frame
    var_0004 = get_item_quality(arg1) --- Guess: Gets item quality
    var_0005 = get_party_members() --- Guess: Gets party members
    for _, var_0008 in ipairs({6, 7, 8, 5}) do
        var_0009 = get_container_items(var_0008, var_0002, var_0003, var_0004) --- Guess: Gets container items
        for _, var_000C in ipairs({10, 11, 12, 9}) do
            if var_000C == arg1 then
                var_0001 = var_0008
                var_000D = get_item_position(var_0001) --- Guess: Gets item position
                var_000D = check_position(arg1) --- Guess: Checks position
            end
        end
    end
    if not var_0001 then
        var_0001 = get_position_data(arg1) --- Guess: Gets position data
        var_000D = update_position(var_0001) --- Guess: Updates position
        var_000D = check_position(arg1) --- Guess: Checks position
    end
end