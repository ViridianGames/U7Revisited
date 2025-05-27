--- Best guess: Cures poison for a character, checking if they are poisoned, deducting gold, and displaying a success or failure message.
function func_091E(P0, P1)
    local var_0000, var_0001

    var_0000 = get_npc_name(P1)
    if not unknown_0088H(8, var_0000) then
        unknown_008AH(8, var_0000)
        var_0001 = unknown_002BH(true, -359, -359, 644, P0)
        add_dialogue("\"The wounds have been healed.\"")
    else
        add_dialogue("\"That individual does not need curing!\"")
    end
end