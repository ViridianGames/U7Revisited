--- Best guess: Manages consumption of food items by mapping item frames to quantities and processing the item, likely for hunger or gameplay effects.
function func_0179(objectref)
    local var_0000, var_0001

    var_0000 = {
        6, 8, 31, 2, 9, 1, 3, 24, 1, 3,
        4, 1, 2, 3, 2, 6, 16, 8, 4, 24,
        24, 16, 24, 12, 1, 3, 3, 5, 2, 6,
        4
    }
    var_0001 = var_0000[get_object_frame(objectref) + 1] --- Guess: Gets quantity based on item frame
    consumeobject_(91, var_0001, objectref) --- Guess: Consumes item with specified quantity
end