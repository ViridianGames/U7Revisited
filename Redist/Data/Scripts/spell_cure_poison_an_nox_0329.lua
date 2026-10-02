--- Best guess: Implements the cure poison spell (An Nox), removing poison status from a selected target.
function utility_spell_0329(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        var_0000 = object_select_modal() --- Guess: Selects spell target
        destroy_object(objectref)
        var_0001 = select_spell_target(var_0000) --- Guess: Gets selected target
        bark(objectref, "@An Nox@")
        if check_spell_requirements() then
            if is_object_valid(var_0000) then
                var_0002 = add_containerobject_s(objectref, {17511, 17509, 8038, 64, 8536, var_0001, 7769})
                var_0002 = add_containerobject_s(var_0000, {6, 1609, 17493, 7715})
            else
                var_0002 = add_containerobject_s(objectref, {1542, 17493, 17511, 17509, 8550, var_0001, 7769})
            end
        else
            var_0002 = add_containerobject_s(objectref, {1542, 17493, 17511, 17509, 8550, var_0001, 7769})
        end
    elseif eventid == 2 then
        clear_item_flag(8, objectref) --- Guess: Sets quest flag
        clear_item_flag(7, objectref) --- Guess: Sets quest flag
    end
end