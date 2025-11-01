--- Best guess: Implements the time acceleration spell (An Tym), speeding up game time.
function utility_spell_0391(eventid, objectref)
    local var_0000

    if eventid == 1 then
        destroyobject_(objectref)
        bark(objectref, "@An Tym@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1671, 17493, 17520, 8042, 67, 7768})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17520, 7786})
        end
    elseif eventid == 2 then
        set_game_speed(100) --- Guess: Sets game speed
    end
end