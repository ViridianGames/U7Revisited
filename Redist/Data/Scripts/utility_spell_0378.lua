--- Best guess: Manages the "Tym Vas Flam" spell, igniting a target (ID 621) with a fiery effect, applying status effects and creating visual items, with a fallback effect if the spell fails.
function utility_spell_0378(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = false
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    var_0001 = object_select_modal()
    var_0002 = utility_unknown_1069(var_0001)
    var_0003 = {var_0001[2], var_0001[3], var_0001[4]}
    bark(objectref, "@Tym Vas Flam@")
    if not utility_unknown_1030() then
        var_0004 = create_new_object(621)
        if not var_0004 then
            set_item_flag(18, var_0004)
            set_item_flag(0, var_0004)
            var_0005 = update_last_created(var_0003)
            if var_0005 then
                var_0005 = set_npc_quality(var_0004, 1, 3)
                var_0005 = set_to_attack(621, var_0004, objectref)
                var_0005 = delayed_execute_usecode_array(12, 7715, 17530, var_0004)
                var_0005 = delayed_execute_usecode_array(14, 7715, 17453, var_0004)
            else
                var_0000 = true
            end
        else
            var_0000 = true
        end
        var_0005 = execute_usecode_array(objectref, {17530, 17519, 17520, 8042, 65, 8536, var_0002, 7769})
        sprite_effect(-1, 0, 0, 0, var_0003[2], var_0003[1], 13)
    else
        var_0000 = true
    end

    if var_0000 then
        var_0005 = execute_usecode_array(objectref, {1542, 17493, 17519, 17520, 8554, var_0002, 7769})
    end
end