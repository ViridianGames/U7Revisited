--- Best guess: Implements the weather control spell (Bet Lor), toggling weather states (e.g., rain) with visual effects.
function utility_spell_0324(eventid, objectref)
    local var_0000

    if eventid == 1 then
        destroy_object(objectref)
        bark(objectref, "@Bet Lor@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1604, 17493, 17511, 8037, 68, 17496, 7715})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17511, 7781})
        end
    elseif eventid == 2 then
        set_weather(110) --- Guess: Sets weather state
    end
end