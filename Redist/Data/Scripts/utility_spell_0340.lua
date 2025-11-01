--- Best guess: Implements the mass cure poison spell (Vas An Nox), curing poison for all party members with visual effects.
function utility_spell_0340(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        destroyobject_(objectref)
        var_0000 = get_object_position(objectref) --- Guess: Gets position data
        apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 7) --- Guess: Applies sprite effect
        bark(objectref, "@Vas An Nox@")
        if check_spell_requirements() then
            var_0001 = add_containerobject_s(objectref, {1620, 8021, 64, 17496, 17511, 17509, 7782})
        else
            var_0001 = add_containerobject_s(objectref, {1542, 17493, 17511, 17509, 7782})
        end
    elseif eventid == 2 then
        var_0002 = get_party_members()
        table.insert(var_0002, 356)
        -- Guess: sloop cures poison for party members
        for i = 1, 5 do
            var_0005 = {3, 4, 5, 2, 23}[i]
            clear_item_flag(8, var_0005) --- Guess: Sets quest flag
            clear_item_flag(7, var_0005) --- Guess: Sets quest flag
        end
    end
end