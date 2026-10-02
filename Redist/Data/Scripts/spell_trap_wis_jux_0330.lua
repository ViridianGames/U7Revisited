--- Best guess: Manages a trap activation mechanic with the spell “Wis Jux,” creating trap items (ID 176) at calculated positions and updating their states.
function utility_spell_0330(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    if eventid ~= 1 then
        var_000C = get_object_position(objectref)
        sprite_effect(-1, 0, 0, 0, var_000C[2], var_000C[1], 16)
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Wis Jux@")
    if not utility_unknown_1030() then
        var_0000 = execute_usecode_array(objectref, {17511, 8037, 66, 7768})
        var_0001 = utility_unknown_1014(-356)
        var_0002 = var_0001 + 21
        var_0003 = find_nearby(176, var_0002, 200, objectref)
        for var_0004 in ipairs(var_0003) do
            var_0000 = delayed_execute_usecode_array(5, {1610, 17493, 7715}, var_0006)
        end
        var_0007 = find_nearby(176, var_0002, 800, objectref)
        var_0008 = find_nearby(176, var_0002, 522, objectref)
        var_0009 = table.insert(var_0007, var_0008)
        for var_000A in ipairs(var_0009) do
            if get_object_quality(var_0006) == 255 then
                var_0000 = delayed_execute_usecode_array(5, {1610, 17493, 7715}, var_0006)
            end
        end
    else
        var_0000 = execute_usecode_array(objectref, {1542, 17493, 17511, 7781})
    end
end