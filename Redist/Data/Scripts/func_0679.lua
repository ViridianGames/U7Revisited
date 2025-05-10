--- Best guess: Implements the death bolt spell (Corp Por), dealing high damage to a target, with special handling for the Avatar (356).
function func_0679(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 or (eventid == 4 and get_object_owner(objectref) == 356) then
        destroyobject_(objectref)
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@Corp Por@")
        if check_spell_requirements() then
            var_0002 = apply_spell_effect(527, var_0000, objectref) --- Guess: Applies spell effect
            var_0002 = add_containerobject_s(objectref, {17530, 17514, 17519, 8048, 65, 17496, 8559, var_0001, 7769})
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17514, 17519, 17520, 8559, var_0001, 7769})
        end
    elseif eventid == 4 and objectref ~= 356 then
        if not is_object_valid(objectref) then
            var_0003 = get_npc_property(2, 356) --- Guess: Gets NPC property
            var_0004 = get_npc_property(2, objectref) --- Guess: Gets NPC property
        else
            var_0003 = 0
            var_0004 = 1
        end
        var_0005 = unknown_0088H(14, objectref) --- Guess: Checks NPC status
        if var_0003 > var_0004 and var_0005 == false then
            damage_npc(objectref, 127) --- Guess: Damages NPC
            kill_npc(objectref) --- Guess: Kills NPC
        end
    end
end