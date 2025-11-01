--- Best guess: Manages the "Vas Uus Sanct" spell, applying a protective effect (ID 109) to party members, with a fallback effect if the spell fails.
function utility_spell_0347(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid ~= 1 then
        if eventid == 2 then
            play_sound_effect(109)
            var_0001 = get_object_position(objectref)
            sprite_effect(-1, 0, 0, 0, var_0001[2] - 2, var_0001[1] - 2, 7)
            var_0002 = get_party_members()
            var_0002 = table.insert(var_0002, -356)
            for var_0003 in ipairs(var_0002) do
                set_item_flag(9, var_0005)
            end
        end
        return
    end

    bark(objectref, "@Vas Uus Sanct@")
    if not utility_unknown_1030() then
        halt_scheduled(objectref)
        var_0000 = execute_usecode_array(objectref, {1627, 17493, 17514, 17519, 17520, 7791})
    else
        var_0000 = execute_usecode_array(objectref, {1542, 17493, 17514, 17519, 17520, 7791})
    end
end