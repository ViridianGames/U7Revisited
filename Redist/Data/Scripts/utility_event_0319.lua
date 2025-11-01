--- Best guess: Triggers a cutscene or event, setting flag 806, centering the view on the Avatar, fading the palette, and manipulating items in a container (ID -356).
function utility_event_0319(eventid, objectref)
    local var_0000

    set_flag(806, true)
    set_camera(-356)
    var_0000 = execute_usecode_array(get_container_objects(359, 359, 359, -356), {1590, 8021, 1814, 17493, 7971, 2, 7719})
    fade_palette(0, 1, 12)
end