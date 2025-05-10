--- Best guess: Destroys an item and sets a quest flag, possibly for quest cleanup.
function func_0619(eventid, objectref)
    destroyobject_(objectref) --- Guess: Destroys item
    unknown_008AH(1, objectref) --- Guess: Sets quest flag
end