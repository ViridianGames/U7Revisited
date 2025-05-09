--- Best guess: Manipulates item type and quality, converting specific items (e.g., type 338 to 997) and adjusting quality.
function func_0600(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = get_item_quality(itemref) - 1 --- Guess: Gets item quality
    var_0001 = set_item_quality(itemref, var_0000) --- Guess: Sets item quality
    if var_0000 == 0 then
        unknown_005CH(itemref) --- Guess: Unknown item operation
        var_0002 = get_item_type(itemref) --- Guess: Gets item type
        if var_0002 == 338 then
            set_item_type(itemref, 997) --- Guess: Sets item type
        end
        if var_0002 == 701 then
            set_item_type(itemref, 595) --- Guess: Sets item type
            var_0001 = set_item_quality(itemref, 255) --- Guess: Sets item quality
        end
        if var_0002 == 435 then
            set_item_type(itemref, 535) --- Guess: Sets item type
        end
        unknown_000FH(106) --- Guess: Unknown operation
    else
        var_0003 = unknown_0002H(50, {1536, 7765}, itemref) --- Guess: Adds item to container
    end
end