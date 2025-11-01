--- Best guess: Processes items with specific types (721, 989), adjusting properties and ownership.
function utility_ship_0904(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014

    var_0001 = false
    var_0002 = false
    var_0003 = false
    var_0004 = set_npc_location(8, 5, -1, objectref) --- Guess: Sets NPC location
    for _, var_0007 in ipairs({4, 5, 6, 7}) do
        var_0008 = random(15, 20) --- Guess: Generates random number
        var_0009 = get_player_stat(var_0007, 2, var_0008, get_npc_property(var_0007, 0)) --- Guess: Gets player stat
        var_000A = get_object_status(var_0007) --- Guess: Gets item status
        if var_000A == 2 then
            var_0001 = true
        elseif var_000A == 3 then
            var_0002 = true
        elseif var_000A == 0 then
            var_0003 = true
        end
    end
    var_0004 = set_npc_location(8, 80, -1, objectref) --- Guess: Sets NPC location
    if var_0001 or var_0002 then
        for _, var_0007 in ipairs({4, 5, 6, 7}) do
            var_000D = get_object_type(var_0007) --- Guess: Gets item type
            if var_000D == 721 or var_000D == 989 then
                set_object_owner(var_0007, 0) --- Guess: Sets item owner
            end
        end
    end
    if var_0003 then
        for _, var_0007 in ipairs({4, 5, 6, 7}) do
            var_000D = get_object_type(var_0007) --- Guess: Gets item type
            if var_000D == 721 or var_000D == 989 then
                set_object_state(var_0007, 2) --- Guess: Sets object state
                set_object_owner(var_0007, 0) --- Guess: Sets item owner
            end
        end
    end
    var_0010 = set_npc_location(0, 5, 270, objectref) --- Guess: Sets NPC location
    for _, var_0013 in ipairs({4, 5, 6, 7}) do
        var_0014 = get_position_data(var_0013) --- Guess: Gets position data
        if var_0014[1] == 2809 and var_0014[2] == 319 and var_0014[3] == 0 then
            remove_item(var_0013) --- Guess: Unknown function, possibly removes item
        end
    end
end