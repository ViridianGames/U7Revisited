--- Best guess: Applies damage to the party or sets game state based on item type and quality, likely for traps or hazards.
function utility_unknown_0804(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = objectref
    if random(1, 3) == 1 and get_object_quality(var_0000) ~= 8 then
        apply_damage_to_party(4, 3, 356) --- Guess: Applies damage to party
        set_object_behavior(objectref, 62) --- Guess: Sets item behavior
        var_0001 = get_object_position(356) --- Guess: Gets position data
        var_0002 = get_object_position(var_0000) --- Guess: Gets position data
        var_0003 = get_object_type(var_0000) --- Guess: Gets item type
        if var_0003 == 776 or var_0003 == 777 or var_0003 == 779 then
            var_0001 = utility_position_0805(2, var_0002, var_0001) --- External call to adjust position
        elseif var_0003 == 157 then
            var_0001 = utility_position_0805(1, var_0002, var_0001) --- External call to adjust position
        end
        move_object(var_0001, 356) --- Guess: Sets NPC target
    else
        set_game_state(0, 1, 12) --- Guess: Sets game state
        set_object_behavior(objectref, 11) --- Guess: Sets item behavior
        utility_position_0803(var_0000) --- External call to update position
        move_object(357, 357) --- Guess: Sets NPC target
        var_0004 = add_containerobject_s(356, {1590, 17493, 7715})
    end
end