--- Best guess: Updates door states based on flag conditions, spawning items for visual effects.
function utility_unknown_0791(objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    var_0000 = objectref
    set_flag(740, var_0000[1])
    set_flag(741, var_0000[2])
    set_flag(742, var_0000[3])
    var_0001 = find_nearby(0, 15, 949, 356) --- Guess: Sets NPC location
    if not get_flag(740) then
        var_0002 = 230
    end
    if not get_flag(741) then
        var_0002 = 220
    end
    if not get_flag(742) then
        var_0002 = 210
    end
    -- Guess: sloop updates door qualities
    for i = 1, 5 do
        var_0005 = ({3, 4, 5, 1, 51})[i]
        if get_object_quality(var_0005) == var_0002 then
            var_0006 = add_containerobject_s(var_0005, {0, 17478, 7969, 16, 17496, 17443, 7937, 1, 7750})
        end
    end
end