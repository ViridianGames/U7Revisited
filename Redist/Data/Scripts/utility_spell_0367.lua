--- Best guess: Manages the "Vas Zu" spell, putting multiple targets (ID -1) within a radius to sleep, with a fallback effect if the spell fails.
function utility_spell_0367(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid ~= 1 then
        if eventid == 2 then
            var_0002 = 25
            var_0003 = find_nearby(4, var_0002, -1, objectref)
            var_0004 = get_party_members()
            for var_0005 in ipairs(var_0003) do
                if not table.contains(var_0004, var_0007) then
                    halt_scheduled(var_0007)
                    set_item_flag(1, var_0007)
                end
            end
        end
        return
    end

    halt_scheduled(objectref)
    var_0000 = get_object_position(objectref)
    bark(objectref, "@Vas Zu@")
    if not utility_unknown_1030() then
        sprite_effect(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 7)
        var_0001 = execute_usecode_array(objectref, {1647, 17493, 17514, 17511, 17519, 17509, 8033, 65, 7768})
    else
        var_0001 = execute_usecode_array(objectref, {1542, 17493, 17514, 17511, 17519, 17509, 7777})
    end
end