--- Best guess: Implements the clone spell (In Quas Xen), duplicating a valid item with specific status checks.
function utility_spell_0369(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        destroy_object(objectref)
        bark(objectref, "@In Quas Xen@")
        if check_spell_requirements() and is_object_valid(var_0000) and get_item_flag(27, 0) ~= -1 then
            var_0002 = add_containerobject_s(objectref, {17514, 17520, 7781})
            var_0002 = add_containerobject_s(var_0000, {4, 1649, 17493, 7715})
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17514, 17520, 7781})
        end
    elseif eventid == 2 then
        var_0002 = cloneobject_(objectref) --- Guess: Clones item
    end
end