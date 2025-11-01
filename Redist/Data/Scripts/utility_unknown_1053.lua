--- Best guess: Heals a character's wounds, restoring health to maximum if injured, deducting gold, and displaying appropriate messages.
function utility_unknown_1053(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = utility_unknown_1040(0, P1)
    var_0001 = utility_unknown_1040(3, P1)
    var_0002 = get_player_name(P1)
    if var_0000 > var_0001 then
        var_0003 = var_0000 - var_0001
        var_0004 = utility_unknown_1042(var_0003, 3, P1)
        var_0005 = remove_party_items(true, -359, -359, 644, P0)
        add_dialogue("\"The wounds have been healed.\"")
    elseif P1 == -356 then
        add_dialogue("\"Thou seemest quite healthy!\"")
    else
        add_dialogue("\"" .. var_0002 .. " is already healthy!\"")
    end
end