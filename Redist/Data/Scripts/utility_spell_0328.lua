--- Best guess: Implements the create food spell (In Mani Ylem), generating food items for party members.
function utility_spell_0328(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        destroyobject_(objectref)
        bark(objectref, "@In Mani Ylem@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1608, 17493, 17511, 17509, 8038, 68, 7768})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17511, 17509, 7782})
        end
    elseif eventid == 2 then
        var_0001 = get_party_members()
        -- Guess: sloop generates food for party members
        for i = 1, 5 do
            var_0004 = {2, 3, 4, 1, 72}[i]
            var_0005 = get_object_position(var_0004) --- Guess: Gets position data
            var_0006 = get_object_status(377) --- Guess: Gets item status
            if var_0006 then
                var_0007 = random(1, 30)
                set_object_frame(var_0006, var_0007)
                set_object_flag(var_0006, 18)
                var_0000 = update_last_created(var_0005) --- Guess: Updates position
            end
        end
    end
end