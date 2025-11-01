--- Best guess: Spawns a sheep (ID 376) and potentially creates a new item (ID 270) if no sheep is found, updating the game state with specific properties.
function utility_unknown_0316(eventid, objectref)
    local var_0000, var_0001

    fade_palette(1, 1, 12)
    var_0000 = find_nearby(0, 6, 376, -356)
    if not var_0000 then
        var_0001 = delayed_execute_usecode_array(1, {6, 8006, 270, 7765}, var_0000)
    end
end