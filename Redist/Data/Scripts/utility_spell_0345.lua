--- Best guess: Implements the heal spell (Mani), restoring NPC health based on property checks.
function utility_spell_0345(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        destroyobject_(objectref)
        bark(objectref, "@Mani@")
        if check_spell_requirements() and is_object_valid(var_0000) then
            var_0002 = add_containerobject_s(objectref, {17511, 17509, 17510, 8033, 64, 17496, 8557, var_0001, 7769})
            var_0002 = add_containerobject_s(var_0000, {5, 1625, 17493, 7715})
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17511, 17509, 17510, 17505, 8557, var_0001, 7769})
        end
    elseif eventid == 2 then
        var_0003 = get_npc_property(0, objectref) --- Guess: Gets NPC property
        var_0004 = get_npc_property(3, objectref) --- Guess: Gets NPC property
        if var_0004 <= var_0003 then
            var_0005 = (var_0003 - var_0004) / 2
            var_0002 = set_npc_property(3, var_0005, objectref) --- Guess: Sets NPC property
        end
    end
end