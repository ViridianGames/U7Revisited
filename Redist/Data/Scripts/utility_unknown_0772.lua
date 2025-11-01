--- Best guess: Finds an item matching frame and quality criteria, destroying it if found.
function utility_unknown_0772(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    var_0000 = objectref
    var_0001 = arg1
    var_0002 = arg2
    var_0003 = find_nearby(16, 30, var_0002, 356) --- Guess: Sets NPC location
    var_0004 = 0
    -- Guess: sloop searches for matching item
    for i = 1, 5 do
        var_0007 = ({5, 6, 7, 3, 55})[i]
        var_0008 = get_object_frame(var_0007) --- Guess: Gets item frame
        var_0009 = get_object_quality(var_0007) --- Guess: Gets item quality
        if var_0008 == var_0001 and (var_0009 == var_0000 or var_0000 == 359) then
            var_0004 = var_0007
        end
    end
    if var_0004 then
        destroy_object_silent(var_0004) --- Guess: Destroys item silently
    end
end