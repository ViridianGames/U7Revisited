--- Best guess: Retrieves a bedroll, adjusting game state and inventory, with conditional item placement based on eventid.
function utility_event_0292(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        close_gumps() --- Guess: Clears game state
        var_0000 = {1, 1, 1, 0, 0, 0, -1, -1, -1}
        var_0001 = {-1, 0, 1, -1, 0, 1, -1, 0, 1}
        destroy_object(356) --- Guess: Destroys item
        set_object_quality(objectref, 7) --- Guess: Sets item property
        set_path_failure(2, objectref, 1572) --- Guess: Sets item event
        var_0002 = add_containerobject_s(356, {8033, 1, 17447, 17516, 17456, 7769})
        if var_0002 then
            var_0002 = add_containerobject_s(356, {1572, 8021, 2, 7719})
        end
    elseif eventid == 2 then
        set_object_type(objectref, 583) --- Guess: Sets item type
        set_object_frame(objectref, 0)
    elseif eventid == 7 then
        close_gumps() --- Guess: Clears game state
        var_0002 = add_containerobject_s(356, {7763, 1, 17447, 17516, 17456, 7769})
        if not var_0002 then
            var_0002 = add_containerobject_s(356, {1572, 8021, 2, 7719})
        end
    end
end