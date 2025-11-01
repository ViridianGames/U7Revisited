--- Best guess: Offers combat training, focusing on sleight of hand and strike feints.
function utility_unknown_0888(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    var_0002 = get_training_target() --- Guess: Gets training target
    if var_0002 == 0 then
        return
    end
    var_0003 = 2
    var_0004 = evaluate_training_ability(var_0003, var_0002, arg1, arg2) --- Guess: Evaluates training ability
    if var_0004 == 0 then
        add_dialogue("@Thou dost not have enough practical experience to study fighting with me...@")
        return
    elseif var_0004 == 1 then
        var_0005 = check_object_ownership(359, 644, 359, 357) --- Guess: Checks item ownership
        add_dialogue("@You gather your gold and count it, finding that you have " .. var_0005 .. " gold altogether.@")
        if var_0005 < var_0000 then
            add_dialogue("@Hmmm... it appears thou art without the necessary amount of gold...@")
            return
        end
    elseif var_0004 == 2 then
        add_dialogue("@Thou art already close in skill to me!...@")
        return
    end
    var_0006 = remove_object_from_inventory(359, 644, 359, var_0000) --- Guess: Removes item from inventory
    add_dialogue("@You pay " .. var_0000 .. " gold, and the training session begins.@")
    var_0007 = get_player_name(var_0002) --- Guess: Gets player name
    var_0008 = start_ceremony() --- Guess: Starts ceremony
    if var_0007 == var_0008 then
        var_0007 = "you"
    end
    add_dialogue("@The session, which consists of various techniques involving sleight of hand and strike feints... " .. var_0007 .. " up and down insolently. 'Thou seemest to be an apt pupil...@")
    var_0009 = get_training_level(4, var_0002) --- Guess: Gets training level
    if var_0009 < 30 then
        improve_combat_skill(var_0002, 2) --- Guess: Improves combat skill
    end
end