--- Best guess: Destroys an item and sets a quest flag, possibly for quest cleanup.
function utility_unknown_0281(eventid, objectref)
    destroyobject_(objectref) --- Guess: Destroys item
    clear_item_flag(1, objectref) --- Guess: Sets quest flag
end