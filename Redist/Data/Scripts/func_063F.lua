-- Triggers a teleportation effect, fading out the palette and centering the view around the Avatar.
function func_063F(eventid, itemref)
    local local0

    set_flag(806, true)
    external_0092H(-356) -- Unmapped intrinsic
    local0 = get_container_items(-359, -359, -359, -356, {1590, 8021, 1814, 17493, 7971, 2, 7719})
    local0 = add_item(-359, local0)
    set_schedule(0, 1, 12)
    return
end