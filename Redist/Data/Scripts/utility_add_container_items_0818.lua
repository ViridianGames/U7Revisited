--- Best guess: Adds items to a container, likely for inventory or event effects.
function utility_event_0818(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002

    var_0000 = eventid
    var_0001 = arg1
    var_0002 = add_containerobject_s(var_0001, {33, 8536, var_0000, 8021, 3, -3, 7947, 32, 17496, 8016, 4, 7750})
end