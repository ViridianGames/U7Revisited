--- Best guess: Initializes Avatar appearance via moongate, adding items to inventory and setting quest flags.
function func_0618(eventid, itemref)
    local var_0000

    if not unknown_0088H(16, 356) then --- Guess: Checks NPC status
        unknown_008AH(16, 356) --- Guess: Sets quest flag
        var_0000 = add_container_items(356, {1562, 8021, 1025, 8021, 10, 7975, 0, 17462, 8019, 0, 17462, 8019, 0, 17462, 7763}) --- Guess: Adds items to container
    end
end