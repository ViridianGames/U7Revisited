--- Best guess: Places items (type 968) around a position, setting a spell duration, likely for an area effect.
function utility_spell_0774(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    var_0000 = objectref
    var_0001 = arg1
    var_0002 = get_object_position(var_0000) --- Guess: Gets position data
    var_0003 = find_nearby(176, 20, var_0001, var_0002) --- Guess: Sets NPC location
    var_0003 = find_nearby(176, 20, var_0001 + 1, var_0002) --- Guess: Sets NPC location
    var_0003 = find_nearby(176, 20, var_0001 + 2, var_0002) --- Guess: Sets NPC location
    var_0003 = find_nearby(176, 20, var_0001 + 3, var_0002) --- Guess: Sets NPC location
    -- Guess: sloop places items around position
    for i = 1, 5 do
        var_0006 = ({4, 5, 6, 3, 31})[i]
        var_0007 = add_containerobject_s(var_0006, {968, 8021, 6, -1, 17419, 7758})
    end
    set_spell_duration(7) --- Guess: Sets spell duration
end