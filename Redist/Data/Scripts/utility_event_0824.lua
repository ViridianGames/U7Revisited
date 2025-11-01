--- Best guess: Adds items to a container based on item frame (8–12), likely for visual or event effects.
function utility_event_0824(eventid, objectref)
    local var_0000, var_0001, var_0002

    var_0000 = objectref
    var_0001 = get_object_frame(var_0000) --- Guess: Gets item frame
    if var_0001 == 8 then
        var_0002 = add_containerobject_s(objectref, {1679, 8021, 25, 7975, 8, 8006, 2, 7719})
    elseif var_0001 == 9 then
        var_0002 = add_containerobject_s(objectref, {1679, 8021, 25, 7975, 8, 8006, 25, 7975, 9, 8006, 2, 7719})
    elseif var_0001 == 10 then
        var_0002 = add_containerobject_s(objectref, {1679, 8021, 25, 7975, 8, 8006, 25, 7975, 9, 8006, 25, 7975, 10, 8006, 2, 7719})
    elseif var_0001 == 11 then
        var_0002 = add_containerobject_s(objectref, {1679, 8021, 25, 7975, 8, 8006, 25, 7975, 9, 8006, 25, 7975, 10, 8006, 25, 7975, 11, 8006, 2, 7719})
    elseif var_0001 == 12 then
        var_0002 = add_containerobject_s(objectref, {1679, 8021, 25, 7975, 8, 8006, 25, 7975, 9, 8006, 25, 7975, 10, 8006, 25, 7975, 11, 8006, 25, 7975, 12, 8006, 2, 7719})
    end
end