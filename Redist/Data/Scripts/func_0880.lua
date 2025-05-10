--- Best guess: Checks and sets item attributes (type, frame) around a position, likely for environmental interactions.
function func_0880(eventid, objectref, positions)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0002 = get_object_type(objectref) --- Guess: Gets item type
    var_0003 = get_object_frame(objectref) --- Guess: Gets item frame
    var_0004 = eventid
    if not set_object_attributes(var_0004, var_0002, var_0003, positions[1] + 1, positions[2] + 1) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] + 1, positions[2] + 2) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1], positions[2] + 1) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] + 1, positions[2] - 1) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] - 1, positions[2] + 1) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] + 1, positions[2] - 2) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] - 2, positions[2] + 1) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] + 1, positions[2] - 3) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] - 3, positions[2] + 1) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] + 1, positions[2] - 4) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] - 4, positions[2] + 1) or
       not set_object_attributes(var_0004, var_0002, var_0003, positions[1] + 1, positions[2] + 1) then
        return
    end
    unknown_003EH(var_0004, objectref) --- Guess: Sets NPC target
end