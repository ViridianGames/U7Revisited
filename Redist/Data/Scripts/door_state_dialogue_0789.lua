--- Best guess: Manages door state (locked/unlocked) with dialogue feedback, tied to quality checks.
---@param objectref integer The door object reference to manage
function utility_unknown_0789(objectref)
    local this_object, var_0001, this_object_quality, var_0003, var_0004

    this_object = objectref
    var_0001 = get_door_state(this_object) --- Guess: Gets door state
    this_object_quality = get_object_quality(objectref) --- Guess: Gets item quality
    var_0003 = -1
    if var_0001 == 0 then
        if this_object_quality == 228 then
            set_flag(737, false)
        end
        if this_object_quality == 247 then
            set_flag(738, false)
        end
        var_0003 = 2
    elseif var_0001 == 1 then
        var_0004 = "@Excuse me, the door is already open. Is it not rather futile to lock it now?@"
        bark(objectref, var_0004) --- Guess: Item says dialogue
    elseif var_0001 == 2 then
        if this_object_quality == 228 then
            set_flag(737, true)
        end
        if this_object_quality == 247 then
            set_flag(738, true)
        end
        var_0003 = 0
    elseif var_0001 == 3 then
        if random(1, 10) == 1 then
            var_0004 = "@Excuse me, the door appears magically locked. Is it not rather difficult to unlock it with a key?@"
            bark(objectref, var_0004) --- Guess: Item says dialogue
        end
    end
    if var_0003 ~= -1 then
        set_door_state(var_0003, this_object) --- Guess: Sets door state
    end
end