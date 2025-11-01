--- Best guess: Checks an item's property (76) and sets a variable based on its value, triggering an action if the value exceeds 6, likely for item state management.
function utility_unknown_1021(var_0000)
    if play_sound_effect(76) > 6 then
        var_0000 = 1
    end
    flash_mouse(var_0000)
    return
end