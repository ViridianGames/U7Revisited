--- Best guess: Handles beer barrel interaction, updating item frames and displaying complaints about wasting beer.
function utility_unknown_0296(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    var_0000 = get_object_status(912) --- Guess: Gets item status
    if var_0000 then
        set_object_flag(var_0000, 18)
        set_object_frame(var_0000, random(15, 12))
        var_0001 = get_object_position(objectref) --- Guess: Gets position data
        var_0002 = find_nearby(0, 2, 810, objectref) --- Guess: Sets NPC location
        -- Guess: sloop checks NPC positions
        for i = 1, 5 do
            var_0005 = ({3, 4, 5, 2, 114})[i]
            var_0006 = get_object_position(var_0005) --- Guess: Gets position data
            if var_0006[1] == var_0001[1] - 1 and var_0006[2] == var_0001[2] + 1 and var_0006[3] == var_0001[3] then
                if get_object_frame(var_0005) == 0 then
                    set_object_frame(var_0005, 4)
                    destroyobject_(objectref)
                    var_0007 = add_containerobject_s(objectref, {1576, 7765})
                end
            end
        end
        var_0001[1] = var_0001[1] + random(1, 3) - 1
        var_0001[2] = var_0001[2] + random(1, 2) - 1
        var_0007 = update_last_created(var_0001) --- Guess: Updates position
        var_0008 = random(1, 2)
        if var_0008 == 1 then
            display_message("@Turn it off!@") --- Guess: Displays message
        elseif var_0008 == 2 then
            display_message("@Thou art wasting it!@") --- Guess: Displays message
        end
        if not npc_in_party(4) then
            bark(4, "@That is perfectly good beer!@")
        end
        destroyobject_(objectref)
        var_0007 = add_containerobject_s(objectref, {1576, 7765})
    end
end