--- Best guess: Manages the "Vas An Xen Ex" spell, freeing a creature or entity (ID 1661) within a radius, with random placement and a fallback effect if the spell fails.
function utility_spell_0381(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid ~= 1 then
        if eventid == 2 then
            var_0007 = get_npc_number(objectref)
            if table.contains({-356, -218, -217}, var_0007) then
                var_0008 = get_alignment(-356)
                if var_0008 then
                    set_item_flag(2, objectref)
                else
                    clear_item_flag(2, objectref)
                end
            end
        end
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas An Xen Ex@")
    if not utility_unknown_1030() then
        var_0000 = execute_usecode_array(objectref, {1661, 17493, 17514, 17519, 17520, 8047, 65, 7768})
        var_0001 = get_object_position(objectref)
        sprite_effect(-1, 0, 0, 0, var_0001[2] - 2, var_0001[1] - 2, 7)
        var_0002 = 25
        var_0003 = utility_unknown_1076(var_0002)
        for var_0004 in ipairs(var_0003) do
            var_0006 = get_distance(var_0006, objectref)
            var_0002 = var_0006 // 4 + 4
            if random2(3, 1) ~= 1 then
                var_0000 = delayed_execute_usecode_array(var_0002, 1661, {17493, 7715}, var_0006)
            end
        end
    else
        var_0000 = execute_usecode_array(objectref, {1542, 17493, 17514, 17519, 17520, 7791})
    end
end