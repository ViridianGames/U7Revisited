--- fn_0698: remove the temporary rodent or cow, restore Erethian, then return to the dialogue through usecode 1686.
function utility_erethian_transform_fx_0408(eventid, objectref)
    local var_0000, var_0003

    -- The pose list calls this as usecode (event 2, world object).
    if objectref == nil then
        objectref = eventid
    end

    var_0000 = get_object_position(objectref)
    -- find_nearby skips GetIsDead leftovers from remove_item.
    local rodent_list = find_nearby(objectref, 521, 1, 4)
    local cow_list = find_nearby(objectref, 500, 1, 4)
    local rodent = (type(rodent_list) == "table") and rodent_list[1] or nil
    local cow = (type(cow_list) == "table") and cow_list[1] or nil
    -- The temporary proxy identifies which failed spell just ran. Remove it,
    -- restore Erethian's frame, then continue the next dialogue stage.
    if rodent then
        apply_sprite_effect(-1, 0, 0, 0, var_0000[3], var_0000[1], 13, var_0000[2])
        play_sound_effect(67)
        remove_item(rodent)
        set_object_frame(objectref, 28)
        -- 1686 is fn_0696. It is first so the next line waits out these poses.
        var_0003 = add_containerobject_s(objectref, {1686, 8021, 3, 17447, 8033, 4, 17447, 8044, 5, 17447, 7789})
        return
    end
    if cow then
        apply_sprite_effect(-1, 0, 0, 0, var_0000[3], var_0000[1], 17, var_0000[2])
        apply_sprite_effect(-1, 0, 0, 0, var_0000[3], var_0000[1], 7, var_0000[2])
        play_sound_effect(62)
        remove_item(cow)
        set_object_frame(objectref, 30)
        var_0003 = add_containerobject_s(objectref, {1686, 8021, 3, 17447, 8033, 4, 17447, 8048, 5, 17447, 7791})
        return
    end
end
