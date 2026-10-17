--- fn_087D: set Avatar item flag 16 and place shape 854, framed from gender and the Avatar's current frame.
function utility_frame_by_gender_0893()
    local avatar = get_npc_name(356)
    if not avatar then
        return
    end

    set_item_flag(avatar, 16)
    local created = create_new_object(854)
    if not created then
        return
    end

    local frame = get_object_frame(avatar)
    if not is_player_female() then
        if frame < 16 then
            set_object_frame(created, 18)
        else
            set_object_frame(created, 19)
        end
    else
        if frame < 16 then
            set_object_frame(created, 20)
        else
            set_object_frame(created, 21)
        end
    end

    update_last_created(get_object_position(avatar))
end
