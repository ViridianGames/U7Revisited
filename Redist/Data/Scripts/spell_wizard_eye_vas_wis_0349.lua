--- Best guess: Manages the "Vas Wis" spell, enhancing visibility or perception (ID 408), with a fallback effect if the spell fails.
function utility_spell_0349(eventid, objectref)
    local var_0000

    if eventid == 1 then
        halt_scheduled(objectref)
        bark(objectref, "@Vas Wis@")
        if not utility_unknown_1030() then
            var_0000 = execute_usecode_array(objectref, {1629, 17493, 17519, 17520, 8047, 67, 7768})
        else
            var_0000 = execute_usecode_array(objectref, {1542, 17493, 17519, 17520, 7791})
        end
    elseif eventid == 2 then
        var_0000 = display_map()
    end
end