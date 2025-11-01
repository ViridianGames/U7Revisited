--- Best guess: Manages the "In Vas Por" spell, causing a mass teleport or movement effect (ID 1662) for party members within a radius, with a fallback effect if the spell fails.
function utility_spellteleport_0382(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid ~= 1 then
        if eventid == 2 then
            set_item_flag(12, objectref)
        end
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@In Vas Por@")
    if not utility_unknown_1030() then
        var_0000 = execute_usecode_array(objectref, {1662, 17493, 17514, 17519, 8048, 64, 17496, 7791})
        var_0001 = get_object_position(objectref)
        sprite_effect(-1, 0, 0, 0, var_0001[2] - 2, var_0001[1] - 2, 7)
        var_0002 = get_party_members()
        for var_0003 in ipairs(var_0002) do
            var_0006 = get_distance(var_0005, objectref)
            var_0000 = delayed_execute_usecode_array(var_0006 // 3 + 5, 1662, {17493, 7715}, var_0005)
        end
    else
        var_0000 = execute_usecode_array(objectref, {1542, 17493, 17514, 17519, 17520, 7791})
    end
end