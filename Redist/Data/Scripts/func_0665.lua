--- Best guess: Implements the reveal spell (Wis Quas), revealing hidden objects or NPCs in a grid pattern around the caster.
function func_0665(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F

    if eventid == 1 then
        destroy_item(itemref)
        var_0000 = unknown_0018H(356) --- Guess: Gets position data
        var_0001 = {}
        bark(itemref, "@Wis Quas@")
        if check_spell_requirements() then
            var_0002 = add_container_items(itemref, {17511, 17510, 8037, 67, 7768})
            var_0003 = unknown_0018H(itemref) --- Guess: Gets position data
            var_0004 = {15, 15, 15, 5, 5, 5, -5, -5, -5, -15, -15, -15}
            var_0005 = {11, 2, -7, 11, 2, -7, 11, 2, -7, 11, 2, -7}
            var_0006 = 7
            var_0007 = 0
            while var_0007 ~= 12 do
                var_0007 = var_0007 + 1
                var_0008 = var_0000[1] + var_0004[var_0007]
                var_0009 = var_0000[2] + var_0005[var_0007]
                var_0003 = {0, var_0009, var_0008}
                var_000A = unknown_0035H(32, var_0006, 359, var_0003) --- Guess: Sets NPC location
                -- Guess: sloop checks nearby objects
                for i = 1, 5 do
                    var_000D = {11, 12, 13, 10, 35}[i]
                    if unknown_0088H(0, var_000D) and not (var_000D == var_0001[1] or var_000D == var_0001[2] or ...) then
                        table.insert(var_0001, var_000D)
                    end
                end
            end
            if var_0001 then
                -- Guess: sloop reveals hidden objects
                for i = 1, 5 do
                    var_000D = {14, 15, 13, 1, 54}[i]
                    var_0002 = add_container_items(var_000D, {5, 1637, 17493, 7715})
                    apply_protection_effect(-1, 0, 0, 0, -1, -1, 13, var_000D) --- Guess: Applies protection effect
                end
            else
                apply_protection_effect(-1, 0, 0, 0, -1, -1, 13, itemref) --- Guess: Applies protection effect
            end
        else
            var_0002 = add_container_items(itemref, {1542, 17493, 17511, 17510, 7781})
        end
    elseif eventid == 2 then
        unknown_008AH(0, itemref) --- Guess: Sets quest flag
    end
end