--- Best guess: Manages a combat training session with Markus, teaching sword techniques and potentially increasing combat ability, with gold and experience checks.
function func_08BD(var_0000, var_0001)
    start_conversation()
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    var_0002 = func_0920()
    var_0003 = get_npc_id_from_name(var_0002)
    if var_0002 == 356 then
        var_0004 = "you"
    else
        var_0004 = var_0003
    end
    var_0005 = 1
    var_0006 = unknown_0922H(var_0005, var_0002, var_0000, var_0001)
    if var_0006 == 0 then
        add_dialogue("\"I am afraid thou dost not have enough practical experience to train at this time. If thou couldst return at a later date, I would be most happy to provide thee with my services.\"")
        return
    elseif var_0006 == 1 then
        var_0007 = unknown_0028H(359, 359, 644, 357)
        add_dialogue("You gather your gold and count it. You have " .. var_0007 .. " altogether.")
        if var_0007 < var_0000 then
            add_dialogue("Markus stretches. He shrugs and says, \"I regret that thou dost not have enough gold to meet my price. Perhaps later, when thou hast made thy fortune pillaging the land...\"")
            return
        end
    end
    add_dialogue("You pay " .. var_0000 .. " gold, and the training session begins.")
    if var_0006 == 2 then
        add_dialogue("Markus blinks and seems to come out of his boredom. \"Thou art already as proficient as I! Thou cannot be trained further here.\"~~Markus returns the gold.")
        return
    end
    var_0008 = unknown_002BH(true, 359, 359, 644, var_0000)
    add_dialogue("\"Very well,\" Markus says, stifling a yawn. \"Here we go.\"~~Markus wields his sword and faces " .. var_0004 .. ". He gives " .. var_0004 .. " a few pointers in stance and balance, then demonstrates some sample thrusts.")
    add_dialogue("Before long, " .. var_0004 .. " and the trainer are trading blows with weapons. He is obviously very good at what he does, and the experience is valuable to " .. var_0004 .. ". When the session is over, it is felt that there has been a gain in combat ability.")
    var_0009 = unknown_0910H(4, var_0002)
    if var_0009 < 30 then
        unknown_0917H(1, var_0002)
    end
    return
end