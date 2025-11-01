--- Best guess: Manages the "Vas Mani" spell (party variant), healing all party members' health by restoring hit points, with a fallback effect if the spell fails.
function utility_spell_0383(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Mani@")
    if not utility_unknown_1030() then
        var_0000 = execute_usecode_array(objectref, {64, 17496, 17514, 17520, 7781})
        var_0001 = get_party_members()
        for var_0002 in ipairs(var_0001) do
            clear_item_flag(7, var_0004)
            clear_item_flag(8, var_0004)
            var_0005 = get_npc_quality(var_0004, 0)
            var_0006 = get_npc_quality(var_0004, 3)
            var_0000 = set_npc_quality(var_0004, 3, var_0005 - var_0006)
            obj_sprite_effect(-1, 0, 0, 0, -1, -1, 13, -356)
        end
    else
        var_0000 = execute_usecode_array(objectref, {1542, 17493, 17514, 17520, 7781})
    end
end