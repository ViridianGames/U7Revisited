--- Best guess: Manipulates item type and quality, converting specific items (e.g., type 338 to 997) and adjusting quality.
function func_0600(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = get_object_quality(objectref) - 1 --- Guess: Gets item quality
    var_0001 = set_object_quality(objectref, var_0000) --- Guess: Sets item quality
    if var_0000 == 0 then
        unknown_005CH(objectref) --- Guess: Unknown item operation
        var_0002 = get_object_type(objectref) --- Guess: Gets item type
        if var_0002 == 338 then
            set_object_type(objectref, 997) --- Guess: Sets item type
        end
        if var_0002 == 701 then
            set_object_type(objectref, 595) --- Guess: Sets item type
            var_0001 = set_object_quality(objectref, 255) --- Guess: Sets item quality
        end
        if var_0002 == 435 then
            set_object_type(objectref, 535) --- Guess: Sets item type
        end
        unknown_000FH(106) --- Guess: Unknown operation
    else
        var_0003 = unknown_0002H(50, {1536, 7765}, objectref) --- Guess: Adds item to container
    end
end