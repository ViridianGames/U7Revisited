--- fn_0881: the shape 854 overlay from 087D, standing on the Avatar's tile in frames 18-21.
--- Not found returns nil. Lua treats 0 as true, so the original's 0 would look like a hit.
function utility_find_items_frames_18_21_0897()
    local avatar = get_npc_name(356)
    if not avatar then
        return nil
    end

    local nearby = find_nearby(avatar, 854, 0, 0)
    if type(nearby) ~= "table" then
        return nil
    end

    for _, item in ipairs(nearby) do
        local frame = get_object_frame(item)
        if frame >= 18 and frame <= 21 then
            return item
        end
    end
    return nil
end
