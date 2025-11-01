--- Best guess: Implements the tremor spell (Vas Por Ylem), causing area-wide effects with random outcomes.
function utility_spell_0375(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    if eventid == 1 then
        destroyobject_(objectref)
        bark(objectref, "@Vas Por Ylem@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1655, 8021, 67, 17496, 17517, 17505, 7784})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17517, 17505, 7784})
        end
    elseif eventid == 2 then
        var_0001 = find_nearby(8, 40, 359, objectref) --- Guess: Sets NPC location
        var_0002 = get_party_members()
        var_0003 = 12
        var_0004 = get_item_flag(6, objectref)
        -- Guess: sloop applies tremor effects
        for i = 1, 5 do
            var_0007 = {5, 6, 7, 1, 462}[i]
            if not var_0004 and not (var_0007 == var_0002[1] or var_0007 == var_0002[2] or ...) then
                var_0008 = 0
                var_0009 = {}
                while var_0008 < var_0003 do
                    var_000A = random(0, 8)
                    if var_000A == 0 then
                        var_000B = {17505, 17516, 7789}
                        var_0009 = {var_000B, var_0009}
                    elseif var_000A == 1 then
                        var_000B = {17505, 17505, 7789}
                        var_0009 = {var_000B, var_0009}
                    elseif var_000A == 2 then
                        var_000B = {17505, 17518, 7788}
                        var_0009 = {var_000B, var_0009}
                    elseif var_000A == 3 then
                        var_000B = {17505, 17505, 7777}
                        var_0009 = {var_000B, var_0009}
                    elseif var_000A == 4 then
                        var_000B = {17505, 17508, 7789}
                        var_0009 = {var_000B, var_0009}
                    elseif var_000A == 5 then
                        var_000B = {17505, 17517, 7780}
                        var_0009 = {var_000B, var_0009}
                    elseif var_000A == 6 then
                        var_000C = 7984 + random(0, 3) * 2
                        var_000B = {17505, 8556, var_000C, 7769}
                        var_0009 = {var_000B, var_0009}
                    elseif var_000A == 7 then
                        var_000C = 7984 + random(0, 3) * 2
                        var_000B = {17505, 8557, var_000C, 7769}
                        var_0009 = {var_000B, var_0009}
                    elseif var_000A == 8 then
                        var_000C = 7984 + random(0, 3) * 2
                        var_000B = {17505, 8548, var_000C, 7769}
                        var_0009 = {var_000B, var_0009}
                    end
                    var_0008 = var_0008 + 1
                end
                destroyobject_(var_0007)
                var_0000 = add_containerobject_s(var_0007, var_0009[1])
            end
        end
        set_spell_duration(var_0003 * 3) --- Guess: Sets spell duration
    end
end