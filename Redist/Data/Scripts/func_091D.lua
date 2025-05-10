--- Best guess: Heals a character’s wounds, restoring health to maximum if injured, deducting gold, and displaying appropriate messages.
function func_091D(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = unknown_0910H(0, P1)
    var_0001 = unknown_0910H(3, P1)
    var_0002 = get_player_name(P1)
    if var_0000 > var_0001 then
        var_0003 = var_0000 - var_0001
        var_0004 = unknown_0912H(var_0003, 3, P1)
        var_0005 = unknown_002BH(true, -359, -359, 644, P0)
        add_dialogue("\"The wounds have been healed.\"")
    elseif P1 == -356 then
        add_dialogue("\"Thou seemest quite healthy!\"")
    else
        add_dialogue("\"" .. var_0002 .. " is already healthy!\"")
    end
end