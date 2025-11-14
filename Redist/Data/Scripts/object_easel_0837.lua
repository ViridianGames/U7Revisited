--- Best guess: Displays a message instructing the player to use a brush and pigments, personalized with the player's name.
function object_easel_0837(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = "@Thou shouldst use the brush and pigments, " .. get_player_name() .. ".@"
        utility_unknown_1023(var_0000)
    end
end