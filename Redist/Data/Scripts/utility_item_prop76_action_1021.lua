--- Best guess: Checks an item's property (76) and sets a variable based on its value, triggering an action if the value exceeds 6, likely for item state management.
---@param flash_value integer The initial flash value (will be set to 1 if sound effect 76 returns > 6)
function utility_unknown_1021(flash_value)
    if play_sound_effect(76) > 6 then
        flash_value = 1
    end
    flash_mouse(flash_value)
end