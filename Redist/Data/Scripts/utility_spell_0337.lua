--- Best guess: Implements the telekinesis spell (Ort Ylem), manipulating specific item types (e.g., levers, switches).
function utility_spell_0337(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    var_0000 = {723, 722}
    var_0001 = {417, 556}
    if eventid == 1 then
        destroyobject_(objectref)
        var_0002 = object_select_modal() --- Guess: Selects spell target
        var_0003 = get_object_type(var_0002)
        var_0004 = select_spell_target(var_0002) --- Guess: Gets selected target
        bark(objectref, "@Ort Ylem@")
        if check_spell_requirements() and (var_0003 == var_0000[1] or var_0003 == var_0000[2]) then
            var_0005 = add_containerobject_s(objectref, {17511, 17509, 8038, 67, 8536, var_0004, 7769})
            var_0005 = add_containerobject_s(var_0002, {4, 1617, 17493, 7715})
        else
            var_0005 = add_containerobject_s(objectref, {1542, 17493, 17511, 17509, 8550, var_0004, 7769})
        end
    elseif eventid == 2 then
        var_0006 = 0
        -- Guess: sloop transforms item types
        for i = 1, 5 do
            var_0006 = var_0006 + 1
            if var_0009 == get_object_type(objectref) then
                set_object_type(objectref, var_0001[var_0006]) --- Guess: Sets item type
            end
        end
    end
end