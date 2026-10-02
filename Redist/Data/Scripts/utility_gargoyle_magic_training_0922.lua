--- Best guess: Manages a gargoyle-led magic training session, checking player intelligence and gold, enhancing mental capabilities if conditions are met.
function utility_unknown_0922(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    var_0002 = utility_unknown_1056()
    var_0003 = get_player_name(var_0002)
    if var_0002 == 0 then
        return
    end
    var_0004 = 3
    var_0005 = utility_unknown_1058(var_0004, var_0002, P0, P1)
    if var_0005 == 0 then
        add_dialogue("\"To see you need more experience to train at this time.\"")
    elseif var_0005 == 1 then
        var_0006 = count_objects(-359, -359, 644, -357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0006 .. " gold altogether.")
        if var_0006 < P0 then
            add_dialogue("\"To have not enough gold to train here.\"")
            return
        end
    elseif var_0005 == 2 then
        add_dialogue("After asking a few questions, he exclaims, \"To be already as well-educated as I. To apologize for my inability to increase your knowledge, but there is nothing I can do.\"")
        return
    end
    var_0007 = remove_party_items(true, -359, -359, 644, P0)
    add_dialogue("You pay " .. P0 .. " gold, and the training session begins.")
    var_0008 = var_0002 == -356 and "you begin" or var_0003 .. " begins"
    add_dialogue("The gargoyle begins with some intense memorization exercises which eventually lead to concepts of spell theory. At the end, " .. var_0008 .. " to notice a change in mental capabilities and thought reaction speed.")
    var_0009 = utility_unknown_1040(2, var_0002)
    if var_0009 < 30 then
        utility_unknown_1046(2, var_0002)
    end
    var_000A = utility_unknown_1040(6, var_0002)
    if var_000A < 30 then
        utility_unknown_1048(1, var_0002)
    end
end