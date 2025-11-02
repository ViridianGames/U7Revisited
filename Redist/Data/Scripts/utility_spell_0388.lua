--- Best guess: Implements the resurrection spell (In Mani Corp), reviving a dead NPC with specific type and quality checks.
function utility_spell_0388(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        var_0000 = object_select_modal() --- Guess: Selects spell target
        var_0001 = get_object_type(var_0000) --- Guess: Gets item type
        var_0002 = get_object_position(var_0000) --- Guess: Gets position data
        var_0003 = select_spell_target(var_0000) --- Guess: Gets selected target
        destroy_object(var_0000)
        destroy_object(objectref)
        if var_0001 == 778 or var_0001 == 414 or var_0001 == 400 then
            var_0004 = get_object_quality(var_0000) --- Guess: Gets item quality
            var_0005 = set_object_count(var_0001, var_0000) --- Guess: Sets item count
            if var_0004 == 0 and var_0005 == 0 then
                var_0006 = 0
            else
                var_0006 = check_object_validity(var_0000) --- Guess: Checks item validity
            end
        else
            var_0006 = 0
        end
        bark(objectref, "@In Mani Corp@")
        if check_spell_requirements() and var_0006 then
            var_0007 = 1
            var_0008 = add_containerobject_s(objectref, {17519, 17505, 8045, 64, 8536, var_0003, 7769})
            play_music(15, 0) --- Guess: Plays music
            apply_sprite_effect(-1, 0, 0, 0, var_0002[2], var_0002[1], 17) --- Guess: Applies sprite effect
            apply_sprite_effect(-1, 0, 0, 0, var_0002[2] - 2, var_0002[1] - 2, 13) --- Guess: Applies sprite effect
        else
            var_0007 = 1
            var_0008 = add_containerobject_s(objectref, {1542, 17493, 17519, 17505, 8557, var_0003, 7769})
        end
    end
end