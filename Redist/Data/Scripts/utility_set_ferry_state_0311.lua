--- Best guess: Sets the ferry state, possibly for scheduling or activation.
function utility_set_ferry_state_0311(eventid, objectref)
    clear_item_flag(26, objectref) --- Guess: Sets quest flag
    set_ferry_state(356) --- Guess: Sets ferry state
end