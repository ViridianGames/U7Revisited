--- Best guess: Manages the "Vas Mani" spell, healing a selected target's health (ID 64) by restoring their hit points, with a fallback effect if the spell fails.
function utility_spell_0364(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid ~= 1 then
        return
    end

    var_0000 = object_select_modal()
    halt_scheduled(var_0000)
    var_0001 = utility_unknown_1069(var_0000)
    bark(objectref, "@Vas Mani@")
    if not utility_unknown_1030() then
        var_0002 = execute_usecode_array(objectref, {64, 17496, 17511, 17509, 8550, var_0001, 7769})
        if not is_npc(var_0000) then
            var_0003 = get_npc_quality(var_0000, 0)
            var_0004 = get_npc_quality(var_0000, 3)
            var_0005 = set_npc_quality(var_0000, 3, var_0003 - var_0004)
        end
    else
        var_0002 = execute_usecode_array(objectref, {1542, 17493, 17511, 17509, 8550, var_0001, 7769})
    end
end