--- Best guess: Manages the "Vas An Zu" spell, awakening sleeping targets (ID -1) within a radius, with a fallback effect if the spell fails.
function utility_spell_0335(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid ~= 1 then
        if eventid == 2 then
            halt_scheduled(objectref)
            clear_item_flag(objectref, 1)
        end
        return
    end

    var_0000 = get_object_position(objectref)
    halt_scheduled(objectref)
    bark(objectref, "@Vas An Zu@")
    if not utility_unknown_1030() then
        sprite_effect(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 7)
        var_0001 = execute_usecode_array(objectref, {17511, 8037, 68, 7768})
        var_0002 = 25
        var_0003 = find_nearby(4, var_0002, -1, objectref)
        for var_0004 in ipairs(var_0003) do
            var_0001 = execute_usecode_array(var_0006, {1615, 17493, 7715})
        end
    else
        var_0001 = execute_usecode_array(objectref, {1542, 17493, 17511, 7781})
    end
end