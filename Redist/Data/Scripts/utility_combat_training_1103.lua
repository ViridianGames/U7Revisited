--- Best guess: Manages a combat training session, checking player strength and gold, enhancing strength if conditions are met.
function utility_unknown_1103(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    var_0002 = utility_unknown_1056()
    var_0003 = get_player_name(var_0002)
    if var_0002 == 0 then
        return
    end
    var_0004 = 3
    var_0005 = utility_unknown_1058(var_0004, var_0002, P0, P1)
    if var_0005 == 0 then
        add_dialogue("After a very quick run, he turns and says, \"Thou dost not yet have the stamina. If thou so wishest, I could train thee at a later date.\"")
        return
    elseif var_0005 == 1 then
        var_0006 = count_objects(-359, -359, 644, -357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0006 .. " gold altogether.")
        if var_0006 < P0 then
            add_dialogue("\"It seems thou dost not have enough gold to train at this time.\"")
            return
        end
    elseif var_0005 == 2 then
        add_dialogue("After a short run, he turns and says, \"Thou art already as strong as I! I am afraid that there is nothing further I can show thee.\"")
        return
    end
    var_0007 = remove_party_items(true, -359, -359, 644, P0)
    add_dialogue("You pay " .. P0 .. " gold, and the training session begins.")
    var_0008 = var_0002 == -356 and "you feel " or var_0003 .. " feels "
    var_0009 = var_0002 == -356 and "you have " or (is_player_female() and "she " or "he ") .. "has "
    add_dialogue("After sparring for half an hour, " .. var_0008 .. " as though " .. var_0009 .. "learned how to better apply force when fighting.")
    var_000C = utility_unknown_1040(0, var_0002)
    if var_000C < 30 then
        utility_unknown_1044(1, var_0002)
    end
    var_000D = utility_unknown_1040(4, var_0002)
    if var_000D < 30 then
        utility_unknown_1047(2, var_0002)
    end
end