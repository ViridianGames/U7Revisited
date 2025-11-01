--- Best guess: Returns the position of an item's owner.
function utility_position_1031(eventid, objectref)
    return get_object_position(get_object_owner(objectref)) --- Guess: Gets item position
end