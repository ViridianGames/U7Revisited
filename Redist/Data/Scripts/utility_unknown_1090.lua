--- Best guess: Manages a torch or candle, setting quality, checking type, and triggering effects or func_0905 for spent items.
function utility_unknown_1090(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0002 = get_object_frame(arg2) --- Guess: Gets item frame
    if not get_object_quality(arg2) then --- Guess: Gets item quality
        var_0003 = set_object_quality(arg2, random(30, 60)) --- Guess: Sets item quality
    end
    if get_object_shape(arg2) == 595 and get_object_quality(arg2) == 255 then --- Guess: Gets item type and quality
        bark(arg2, "@Spent@") --- Guess: Item says dialogue
    end
    var_0004 = get_object_container(arg2) --- Guess: Gets item container
    if var_0004 == 0 or check_object_status(var_0004) then --- Guess: Checks item status
        set_object_type(arg1, objectref) --- Guess: Sets item type
        var_0005 = get_party_members() --- Guess: Gets party members
        if is_int_in_array(var_0004, var_0005) then
            utility_unknown_1029(arg2) --- External call to func_0905
        else
            trigger_flash_effect(0) --- Guess: Triggers flash effect
        end
    end
    set_object_property(arg2, true) --- Guess: Sets item property
    reset_object_state() --- Guess: Resets item state
end