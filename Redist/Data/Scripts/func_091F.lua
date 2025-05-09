--- Best guess: Resurrects a character, deducting gold if successful, and displays a success or failure message.
function func_091F(P0, P1)
    local var_0000, var_0001

    var_0000 = unknown_0051H(P1)
    if var_0000 then
        add_dialogue("\"Breath doth return to the body. Thy comrade is alive!\"")
        var_0001 = unknown_002BH(true, -359, -359, 644, P0)
    else
        add_dialogue("\"Alas, I cannot save thy friend. I will provide a proper burial. Thou must go on and continue with thine own life.\"")
    end
end