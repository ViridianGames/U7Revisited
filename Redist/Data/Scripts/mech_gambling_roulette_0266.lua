--- Best guess: Manages a gambling game mechanic, likely a slot machine or roulette, determining outcomes based on item frame colors (Blue, Black, White, etc.), calculating wins/losses, and updating game state with flag-based NPC dialogue.
function utility_unknown_0266(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011

    if eventid ~= 2 then
        return
    end

    if get_schedule_type(232) == 9 then
        set_schedule_type(10, 232)
    end

    var_0000 = find_nearby(0, 7, 520, objectref)
    var_0001 = find_nearby(0, 5, 644, var_0000)
    var_0002 = 0
    var_0003 = 0
    var_0004 = get_object_frame(objectref)
    var_0005 = var_0004 // 4

    if var_0005 == 0 then
        var_0002 = -3
        var_0003 = -1
        var_0006 = "Blue"
    elseif var_0005 == 1 then
        var_0002 = 0
        var_0003 = 0
        var_0006 = "Black"
    elseif var_0005 == 2 then
        var_0002 = -1
        var_0003 = 0
        var_0006 = "White"
    elseif var_0005 == 3 then
        var_0002 = -2
        var_0003 = 0
        var_0006 = "Purple"
    elseif var_0005 == 4 then
        var_0002 = -3
        var_0003 = 0
        var_0006 = "Orange"
    elseif var_0005 == 5 then
        var_0002 = 0
        var_0003 = -1
        var_0006 = "Green"
    elseif var_0005 == 6 then
        var_0002 = -1
        var_0003 = -1
        var_0006 = "Red"
    elseif var_0005 == 7 then
        var_0002 = -2
        var_0003 = -1
        var_0006 = "Yellow"
    end

    var_0007 = false
    if not npc_in_party(232) then
        var_0008 = {}
        var_0009 = ""
    else
        var_0009 = "@Didst thou win?@"
        utility_unknown_1022(var_0009)
    end

    if not get_flag(6) then
        var_000A = 14
    else
        var_000A = 7
    end

    for var_000B in ipairs(var_0001) do
        var_000E = get_object_position(var_000D)
        var_000F = get_object_position(var_0000)
        if var_000E[1] + var_0002 == var_000F[1] and var_000E[2] + var_0003 == var_000F[2] then
            set_item_flag(11, var_000D)
            var_0010 = get_item_quantity(0, var_000D)
            var_0010 = var_0010 * var_000A
            while var_0010 > 100 do
                var_0008 = create_new_object(644)
                if var_0008 then
                    var_0011 = set_item_quantity(var_0010, var_0008)
                    var_0011 = update_last_created(var_000E)
                end
                var_0010 = var_0010 - 100
            end
            var_0008 = create_new_object(644)
            if var_0008 then
                var_0011 = set_item_quantity(var_0010, var_0008)
                var_0011 = update_last_created(var_000E)
            end
            if not utility_unknown_1079(232) then
                utility_unknown_1028(232, "@A winner on " .. var_0006 .. ".@")
            end
            var_0007 = true
        end
        remove_item(var_000D)
    end

    if not var_0007 and not utility_unknown_1079(232) then
        utility_unknown_1028(232, "@It is " .. var_0006 .. ".@")
    end
end