--- Best guess: Disables a game flag (ID 749) and triggers a game mode switch, likely for a specific event or state reset.
function utility_clear_flag749_weather_0394(eventid, objectref)
    set_flag(749, false)
    set_weather(0)
end