--- Best guess: Advances Horance’s Well of Souls quest dialogue, checking party members and flags to guide the player toward finding a sacrificial spirit.
function func_08AF()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003

    unknown_0003H(1, -141)
    var_0000 = unknown_0023H()
    if not (unknown_001BH(-147) in var_0000) then
        add_dialogue("\"Is there a problem? Art thou confounded by thy task?\"")
        var_0001 = unknown_090AH()
        if not var_0001 then
            add_dialogue("\"Well then, I suggest that thou hasten to finish thy task, lest the souls of the well perish before thou art done.\"")
            return
        else
            add_dialogue("\"Canst thou not find the spirits of the town?\"")
            var_0002 = unknown_090AH()
            if not var_0002 then
                add_dialogue("\"Well then, I suggest that thou make haste, lest the souls of the well perish.\"")
                return
            else
                add_dialogue("\"Ah, then it is good that thou hast returned. The Mayor knows most of the townsfolk and can tell thee of them.\"")
                return
            end
        end
    elseif not get_flag(419) then
        add_dialogue("\"Very good, now thou shalt take the Mayor to the well and he must enter it of his own free will. When he does that, the souls of the island and the well will be free to go on to their destiny. Unfortunately, Mayor Forsythe will be lost for all time.\"")
        var_0003 = unknown_08F7H(-147)
        if var_0003 then
            add_dialogue(" He looks sadly at the ghostly gentleman.")
        end
        add_dialogue("*")
    elseif not get_flag(427) then
        unknown_08B1H()
    else
        unknown_08B2H()
    end
    return
end