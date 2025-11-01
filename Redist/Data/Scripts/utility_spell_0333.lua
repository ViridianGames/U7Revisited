--- Best guess: Manages the "In Lor" spell, creating a light source (ID 500) with specific properties, with a fallback effect if the spell fails.
function utility_spell_0333(eventid, objectref)
    local var_0000

    if eventid == 1 then
        halt_scheduled(objectref)
        bark(objectref, "@In Lor@")
        if not utility_unknown_1030() then
            var_0000 = execute_usecode_array(objectref, {1613, 17493, 17511, 8037, 68, 17496, 7715})
        else
            var_0000 = execute_usecode_array(objectref, {1542, 17493, 17511, 7781})
        end
    elseif eventid == 2 then
        cause_light(500)
    end
end