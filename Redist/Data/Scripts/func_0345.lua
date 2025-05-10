--- Best guess: Displays a message instructing the player to use a brush and pigments, personalized with the player’s name.
function func_0345(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = "@Thou shouldst use the brush and pigments, " .. unknown_0908H() .. ".@"
        unknown_08FFH(var_0000)
    end
end