--- Best guess: Manages a newly lit torch, destroying it and setting properties.
function func_0905(eventid, itemref)
    local var_0000, var_0001

    destroy_item(itemref) --- Guess: Destroys item
    set_item_property(itemref, true) --- Guess: Sets item property
    reset_item_state() --- Guess: Resets item state
    var_0001 = add_container_items(itemref, {50, 1536, 17493, 7715}) --- Guess: Adds items to container
end