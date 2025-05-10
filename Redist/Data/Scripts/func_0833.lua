--- Best guess: Adds items to a container with different parameters, likely for inventory or event effects.
function func_0833(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002

    var_0000 = eventid
    var_0001 = arg1
    var_0002 = add_containerobject_s(var_0001, {33, 8024, 3, -3, 7947, 32, 17496, 8526, var_0000, 7765})
end