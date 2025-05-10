--- Best guess: Manages Erethian's failed transformations (rodent, cow) with sound effects and visual effects.
function func_0697(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    var_0000 = unknown_0018H(objectref) --- Guess: Gets position data
    if not get_flag(3) then
        if not get_flag(811) then
            set_flag(811, true)
            apply_sprite_effect(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 13) --- Guess: Applies sprite effect
            apply_sprite_effect(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 7) --- Guess: Applies sprite effect
            unknown_000FH(67) --- Guess: Triggers event
            set_object_frame(objectref, 4) --- Guess: Sets item frame
            var_0001 = get_object_status(274) --- Guess: Gets item status
            set_object_frame(var_0001, 28) --- Guess: Sets item frame
            var_0002 = unknown_0026H(var_0000) --- Guess: Updates position
            var_0003 = add_containerobject_s(objectref, {1686, 8021, 16, 7719})
            var_0004 = add_containerobject_s(var_0001, {8035, 2, 17447, 8044, 3, 17447, 8045, 4, 17447, 7769})
        elseif not get_flag(812) then
            set_flag(812, true)
            apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 17) --- Guess: Applies sprite effect
            apply_sprite_effect(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 4) --- Guess: Applies sprite effect
            unknown_000FH(9) --- Guess: Triggers event
            set_object_frame(objectref, 4) --- Guess: Sets item frame
            var_0005 = get_object_status(504) --- Guess: Gets item status
            var_0006 = set_object_type_at(154, var_0005, 1) --- Guess: Sets item type at position
            var_0003 = add_containerobject_s(objectref, {1686, 8021, 14, 7719})
            var_0007 = add_containerobject_s(var_0005, {8033, 4, 17447, 8044, 5, 17447, 7789})
            var_0002 = unknown_0026H(var_0000) --- Guess: Updates position
            unknown_001DH(29, var_0006)
            unknown_008AH(16, 356) --- Guess: Sets quest flag
            var_0008 = get_conversation_target() --- Guess: Gets conversation target
            var_0009 = add_containerobject_s(var_0008, {13, 17453, 7724})
            var_000A = add_containerobject_s(356, {1693, 8021, 11, 7719})
            bark(objectref, "@Squeak!@")
        end
    elseif not get_flag(811) then
        set_flag(811, true)
        apply_sprite_effect(-1, 0, 0, 0, var_0000[2], var_0000[1], 17) --- Guess: Applies sprite effect
        apply_sprite_effect(-1, 0, 0, 0, var_0000[2] - 2, var_0000[1] - 2, 7) --- Guess: Applies sprite effect
        unknown_000FH(62) --- Guess: Triggers event
        set_object_frame(objectref, 4) --- Guess: Sets item frame
        var_000D = get_object_status(500) --- Guess: Gets item status
        set_object_frame(var_000D, 23) --- Guess: Sets item frame
        var_0002 = unknown_0026H(var_0000) --- Guess: Updates position
        var_0003 = add_containerobject_s(objectref, {1688, 8021, 7, 7463, "@MOO?!@", 8018, 11, 7719})
        var_000E = add_containerobject_s(var_000D, {8040, 1, 17447, 8041, 1, 17447, 8042, 2, 17447, 8041, 2, 17447, 8042, 1, 17447, 8041, 1, 17447, 8040, 4, 7975, 4, 7769})
        bark(objectref, "@MOO?!@")
    end
end