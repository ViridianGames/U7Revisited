-- Function 0905: Light torch effect
function func_0905(eventid, itemref)
    local local0

    set_item_glow(itemref)
    play_sound_effect(true, itemref)
    update_game_state()
    local1 = follow_wall(50, itemref, {17493, 7715, 1536})
    return
end