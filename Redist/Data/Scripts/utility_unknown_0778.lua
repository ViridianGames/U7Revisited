--- Best guess: Manages a seating arrangement mechanic, finding nearby seats (P0) and assigning party members to the closest available seat (P1), excluding the clicked seat.
function utility_unknown_0778(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013

    var_0002 = {}
    var_0003 = find_nearby(0, 15, P0, get_npc_name(-356))
    for var_0004 in ipairs(var_0003) do
        var_0007 = 0
        var_0008 = 9999
        for var_0009 in ipairs(var_0003) do
            var_0007 = var_0007 + 1
            if var_000B ~= 0 and var_000B ~= P1 then
                var_000C = get_distance(var_000B, P1)
                if var_000C < var_0008 then
                    var_0008 = var_000C
                    var_000D = var_0007
                end
            end
        end
        table.insert(var_0002, var_0003[var_000D])
        var_0003[var_000D] = 0
    end
    sit_down(P1, get_npc_name(-356))
    var_000E = #var_0002
    var_000F = get_party_members()
    var_0007 = 2
    for var_0010 in ipairs(var_000F) do
        if var_0007 - 1 > var_000E then
            break
        end
        if get_schedule_type(var_0012) ~= 16 then
            var_0013 = var_0007 - 1
            sit_down(var_0002[var_0013], var_0012)
        end
        var_0007 = var_0007 + 1
    end
end