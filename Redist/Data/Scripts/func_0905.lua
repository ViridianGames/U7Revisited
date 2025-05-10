--- Best guess: Manages a newly lit torch, destroying it and setting properties.
function func_0905(eventid, objectref)
    local var_0000, var_0001

    destroyobject_(objectref) --- Guess: Destroys item
    set_object_property(objectref, true) --- Guess: Sets item property
    reset_object_state() --- Guess: Resets item state
    var_0001 = add_containerobject_s(objectref, {50, 1536, 17493, 7715}) --- Guess: Adds items to container
end