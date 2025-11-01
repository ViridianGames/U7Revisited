--- Best guess: Implements the poison storm spell (Vas In Flam Grav), creating a poison field with random damage.
function utility_spell_0371(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    if eventid == 1 then
        var_0000 = 25
        var_0001 = get_nearby_npcs(var_0000) --- Guess: Gets nearby NPCs
        destroyobject_(objectref)
        bark(objectref, "@Vas In Flam Grav@")
        if check_spell_requirements() then
            var_0002 = add_containerobject_s(objectref, {17514, 17520, 17516, 17517, 8044, 65, 7768})
            -- Guess: sloop creates poison field
            for i = 1, 5 do
                var_0005 = {3, 4, 5, 1, 147}[i]
                var_0006 = get_object_position(var_0005) --- Guess: Gets position data
                var_0007 = var_0006[1]
                var_0008 = var_0006[2]
                var_0009 = var_0006[3]
                var_000A = {0, var_0008, var_0007}
                var_000B = get_object_status(895) --- Guess: Gets item status
                if var_000B then
                    var_0002 = update_last_created(var_000A) --- Guess: Updates position
                    var_000C = random(1, 15)
                    var_000D = 30 + var_000C
                    var_0002 = set_object_quality(var_000B, var_000D)
                    set_object_flag(var_000B, 18)
                    var_0002 = add_containerobject_s(var_000B, {var_000D, 17453, 7715})
                end
            end
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17514, 17520, 17516, 17517, 7788})
        end
    end
end