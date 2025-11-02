--- Best guess: Manages a password-protected door (password: Blackbird), checking NPC status and updating door state.
function utility_unknown_0305(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    start_conversation()
    if eventid == 7 then
        var_0000 = get_object_quality(objectref) --- Guess: Gets item quality
        var_0001 = find_nearby(0, 15, 870, objectref) --- Guess: Sets NPC location
        var_0002 = find_nearby(0, 15, 515, objectref) --- Guess: Sets NPC location
        var_0001 = {var_0001, var_0002}
        var_0002 = {}
        -- Guess: sloop filters items by quality
        for i = 1, 5 do
            var_0005 = ({3, 4, 5, 1, 27})[i]
            if get_object_quality(var_0005) == var_0000 then
                table.insert(var_0002, var_0005)
            end
        end
        if check_nearby_objects(var_0002) then --- Guess: Checks nearby objects
            var_0006 = add_containerobject_s(objectref, {4, 17419, 8014, 1, 7750})
            var_0006 = add_containerobject_s(356, {2, 17419, 17505, 17516, 7937, 6, 7769})
        end
        if not get_flag(61) then
            if npc_id_in_party(14) and not get_flag(343) and check_npc_status(14) and check_npc_status(356) then
                var_0006 = add_containerobject_s(get_object_ref(14), {1, "@What's the password?@", 17490, 7715})
                var_0006 = add_containerobject_s(objectref, {5, "@Blackbird@", 17490, 7715})
                var_0006 = add_containerobject_s(get_object_ref(14), {11, "@Pass.@", 17490, 7715})
            end
            var_0006 = add_containerobject_s(objectref, {10, 1585, 17493, 7715})
        elseif npc_id_in_party(27) and not get_flag(343) and check_npc_status(27) and check_npc_status(356) then
            var_0006 = add_containerobject_s(get_object_ref(27), {1, "@What's the password?@", 17490, 7715})
            var_0006 = add_containerobject_s(objectref, {5, "@Blackbird@", 17490, 7715})
            var_0006 = add_containerobject_s(get_object_ref(27), {11, "@Pass.@", 17490, 7715})
            var_0006 = add_containerobject_s(objectref, {10, 1585, 17493, 7715})
        elseif in_combat(806, 356) and not get_flag(343) then
            var_0007 = in_combat(20, 806, objectref) --- Guess: Checks item type
            if check_npc_status(var_0007) and check_npc_status(356) then
                var_0006 = add_containerobject_s(var_0007, {1, "@What's the password?@", 17490, 7715})
                var_0006 = add_containerobject_s(objectref, {5, "@Blackbird@", 17490, 7715})
                var_0006 = add_containerobject_s(var_0007, {11, "@Pass.@", 17490, 7715})
            end
            var_0006 = add_containerobject_s(objectref, {10, 1585, 17493, 7715})
        else
            if not npc_id_in_party(14) and not get_flag(343) then
                var_0006 = add_containerobject_s(get_object_ref(14), {1, "@What's the password?@", 17490, 7715})
            end
            if npc_id_in_party(27) and not get_flag(343) then
                var_0006 = add_containerobject_s(get_object_ref(14), {1, "@What's the password?@", 17490, 7715})
            end
            if not in_combat(806, 356) then
                var_0007 = in_combat(20, 806, objectref) --- Guess: Checks item type
                if check_npc_status(var_0007) then
                    var_0006 = add_containerobject_s(var_0007, {1, "@What's the password?@", 17490, 7715})
                end
            end
            set_door_state(objectref, true) --- Guess: Sets door state
        end
    elseif eventid == 2 then
        set_door_state(objectref, true) --- Guess: Sets door state
    end
end