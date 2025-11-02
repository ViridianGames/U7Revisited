--- Best guess: Triggers a complex sequence of effects on nearby items and party members when event ID 3 is received, with random selections and array-based operations.
function utility_event_0445(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    if eventid == 3 then
        var_0000 = find_nearby(8, 40, 359, objectref)
        var_0001 = get_party_list2()
        var_0002 = 10
        var_0003 = get_item_flag(6, objectref)
        for i = 1, #var_0000 do
            var_0006 = var_0000[i]
            if not var_0003 then -- TODO:  or not (var_0006 in var_0001)
                var_0007 = 0
                var_0008 = ""
                while var_0007 < var_0002 do
                    var_0009 = die_roll(8, 0)
                    if var_0009 == 0 then
                        var_000A = {17505, 17516, 7789}
                        var_0008 = {var_0008, var_000A}
                    elseif var_0009 == 1 then
                        var_000A = {17505, 17505, 7789}
                        var_0008 = {var_0008, var_000A}
                    elseif var_0009 == 2 then
                        var_000A = {17505, 17518, 7788}
                        var_0008 = {var_0008, var_000A}
                    elseif var_0009 == 3 then
                        var_000A = {17505, 17505, 7777}
                        var_0008 = {var_0008, var_000A}
                    elseif var_0009 == 4 then
                        var_000A = {17505, 17508, 7789}
                        var_0008 = {var_0008, var_000A}
                    elseif var_0009 == 5 then
                        var_000A = {17505, 17517, 7780}
                        var_0008 = {var_0008, var_000A}
                    elseif var_0009 == 6 then
                        var_000B = 7984 + die_roll(3, 0) * 2
                        var_000A = {17505, 8556, var_000B, 7769}
                        var_0008 = {var_0008, var_000A}
                    elseif var_0009 == 7 then
                        var_000B = 7984 + die_roll(3, 0) * 2
                        var_000A = {17505, 8557, var_000B, 7769}
                        var_0008 = {var_0008, var_000A}
                    elseif var_0009 == 8 then
                        var_000B = 7984 + die_roll(3, 0) * 2
                        var_000A = {17505, 8548, var_000B, 7769}
                        var_0008 = {var_0008, var_000A}
                    end
                    var_0007 = var_0007 + 1
                end
                halt_scheduled(var_0006)
                var_000C = execute_usecode_array(var_0008, var_0006)
            end
        end
        earthquake(var_0002 * 3)
    end
    return
end