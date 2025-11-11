--- Best guess: Manages a torch or candle, setting quality, checking type, and triggering effects or func_0905 for spent items.
---@param shape_id integer The shape ID for the object type
---@param objectref integer The object reference for the torch or candle
function utility_unknown_1090(shape_id, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0002 = get_object_frame(objectref) --- Guess: Gets item frame
    if not get_object_quality(objectref) then --- Guess: Gets item quality
        var_0003 = set_object_quality(objectref, random(30, 60)) --- Guess: Sets item quality
    end
    if get_object_shape(objectref) == 595 and get_object_quality(objectref) == 255 then --- Guess: Gets item type and quality
        bark(objectref, "@Spent@") --- Guess: Item says dialogue
    end
    var_0004 = get_object_container(objectref) --- Guess: Gets item container
    if var_0004 == 0 or check_object_status(var_0004) then --- Guess: Checks item status
        set_object_shape(shape_id, objectref) --- Guess: Sets item type
        var_0005 = get_party_members() --- Guess: Gets party members
        if is_int_in_array(var_0004, var_0005) then
            utility_unknown_1029(objectref) --- External call to func_0905
        else
            trigger_flash_effect(0) --- Guess: Triggers flash effect
        end
    end
    set_object_property(arg2, true) --- Guess: Sets item property
    reset_object_state() --- Guess: Resets item state
end