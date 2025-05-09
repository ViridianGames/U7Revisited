--- Best guess: Manages ship gangplank and sail status to enable sailing, displaying a message if the gangplank is blocked and configuring item ownership.
function func_0831(itemref)
    local var_0000, var_0001, var_0002, var_0005, var_0006

    start_conversation()
    var_0000 = itemref
    var_0001 = {get_position_data(var_0000), get_item_quality(var_0000), -359} --- Guess: Builds array with position, quality, and player ID
    var_0002 = find_nearby_items(0, 12, 150, var_0001) --- Guess: Finds nearby gangplank items
    for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
        var_0005 = var_0002[i]
        if var_0005 then
            if not check_gangplank_state(var_0005) then --- Guess: Checks gangplank status
                display_message("@One of the gangplanks seems to be blocked. It must be lowered to sail.@") --- Guess: Displays message
            end
        end
    end
    var_0006 = find_nearby_items(0, 18, 251, var_0001) --- Guess: Finds nearby sail items
    check_sail_state(var_0006, 1) --- Guess: Checks sail status
    set_item_owner_attribute(-356, 20) --- Guess: Sets attribute for item owner
    set_item_owner(var_0000, 10) --- Guess: Sets item owner
    set_item_owner(get_item_owner_attribute(-356, 26), 20) --- Guess: Sets owner based on attribute
end