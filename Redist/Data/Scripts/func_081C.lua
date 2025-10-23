--- Best guess: Adjusts an item's frame (P1) by adding a value (P0) and ensuring the result is modulo 4, updating the item's frame.
function func_081C(P0, P1)
    local var_0000, var_0001, var_0002, var_0003

    var_0002 = get_object_frame(P1)
    var_0003 = var_0002 % 4
    set_object_frame(P1, var_0002 - var_0003 + P0)  -- Fixed: was get_object_frame, should be set_object_frame
end