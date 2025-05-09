--- Best guess: Implements the great light spell (Vas Lor), illuminating a large area with weather-like effects.
function func_0653(eventid, itemref)
    local var_0000

    if eventid == 1 then
        destroy_item(itemref)
        bark(itemref, "@Vas Lor@")
        if check_spell_requirements() then
            var_0000 = add_container_items(itemref, {1619, 17493, 17511, 8037, 68, 17496, 7715})
        else
            var_0000 = add_container_items(itemref, {1542, 17493, 17511, 7781})
        end
    elseif eventid == 2 then
        set_weather_state(5000) --- Guess: Sets weather state
    end
end