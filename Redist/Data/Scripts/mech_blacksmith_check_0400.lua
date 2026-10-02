--- Best guess: Handles item type checks (e.g., 707, 760) and triggers func_0691 for blacksmithing interactions.
function utility_unknown_0400(eventid, objectref)
    local var_0000, var_0001

    var_0000 = get_object_shape(objectref) --- Guess: Gets item type
    if var_0000 == 707 then
        var_0001 = add_containerobject_s(objectref, {1782, 8021, 1, 7719})
    elseif var_0000 == 760 then
        var_0001 = add_containerobject_s(objectref, {1782, 8021, 1, 7719})
    end
    if eventid == 1 then
        var_0001 = add_containerobject_s(objectref, {623, 8021, 1, 7719})
    elseif eventid == 2 then
        utility_unknown_0401(objectref) --- External call to blacksmithing function
    end
end