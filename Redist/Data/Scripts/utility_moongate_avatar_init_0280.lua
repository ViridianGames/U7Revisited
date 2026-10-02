--- Best guess: Initializes Avatar appearance via moongate, adding items to inventory and setting quest flags.
function utility_unknown_0280(eventid, objectref)
    local var_0000

    if not get_item_flag(16, 356) then --- Guess: Checks NPC status
        clear_item_flag(16, 356) --- Guess: Sets quest flag
        var_0000 = add_containerobject_s(356, {1562, 8021, 1025, 8021, 10, 7975, 0, 17462, 8019, 0, 17462, 8019, 0, 17462, 7763}) --- Guess: Adds items to container
    end
end