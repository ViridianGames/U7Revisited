--- Best guess: Spawns and destroys items (type 981, 776) with positioning, likely for an event or effect.
function utility_event_0773(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    var_0000 = objectref
    if not get_flag(4) then
        set_object_type(981, var_0000) --- Guess: Sets item type
        var_0001 = {0, 1120, 535}
        move_object(var_0001, var_0000) --- Guess: Sets NPC target
        var_0001[2] = var_0001[2] + 2
        move_object(var_0001, 356) --- Guess: Sets NPC target
        utility_event_0776() --- External call to party management
        var_0002 = find_nearby(16, 10, 776, 356) --- Guess: Sets NPC location
        -- Guess: sloop destroys items
        for i = 1, 5 do
            var_0005 = ({3, 4, 5, 2, 10})[i]
            destroy_object_silent(var_0005) --- Guess: Destroys item silently
        end
        var_0006 = add_containerobject_s_at(356, {8, 1563, 17493, 7715})
        set_flag(4, true)
    end
end