--- Best guess: Manages a newly lit torch, destroying it and setting properties.
---@param objectref integer The object reference ID to destroy and modify
function utility_unknown_1029(objectref)
    local var_0000, var_0001

    destroy_object(objectref) --- Guess: Destroys item
    set_object_property(objectref, true) --- Guess: Sets item property
    reset_object_state() --- Guess: Resets item state
    var_0001 = add_containerobject_s(objectref, {50, 1536, 17493, 7715}) --- Guess: Adds items to container
end