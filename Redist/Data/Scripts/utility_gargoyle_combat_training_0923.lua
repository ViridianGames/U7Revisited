--- Best guess: Manages a gargoyle-led combat training session, checking player strength and gold, enhancing physical prowess if conditions are met.
---@param training_cost integer The gold cost for the training session
---@param max_stat_value integer The maximum stat value allowed for training
function utility_unknown_0923(training_cost, max_stat_value)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    var_0002 = utility_unknown_1056()
    var_0003 = get_player_name(var_0002)
    var_0004 = var_0002 == -356 and "your" or "their"
    if var_0002 == 0 then
        return
    end
    var_0005 = 3
    var_0006 = utility_unknown_1058(var_0005, var_0002, training_cost, max_stat_value)
    if var_0006 == 0 then
        add_dialogue("\"To be without the practical experience required to train at this time.\"")
    elseif var_0006 == 1 then
        var_0007 = count_objects(-359, -359, 644, -357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0007 .. " gold altogether.")
        if var_0007 < training_cost then
            add_dialogue("\"To need more gold than you have. To need 50 gold.\"")
            return
        end
    elseif var_0006 == 2 then
        add_dialogue("After examining " .. var_0004 .. " muscles, he says, \"To be stronger than I. To need no further training in combat.\"")
        return
    end
    var_0008 = remove_party_items(true, -359, -359, 644, training_cost)
    add_dialogue("You pay " .. training_cost .. " gold, and the training session begins.")
    var_0009 = var_0002 == -356 and "you begin" or var_0003 .. " begins"
    add_dialogue("The gargoyle begins with some intense weight-lifting which eventually leads to target practice with throwing axes. At the end, " .. var_0009 .. " to notice a change in physical prowess and hand-eye coordination.")
    var_000A = utility_unknown_1040(0, var_0002)
    if var_000A < 30 then
        utility_unknown_1044(1, var_0002)
    end
    var_000B = utility_unknown_1040(1, var_0002)
    if var_000B < 30 then
        utility_unknown_1045(1, var_0002)
    end
    var_000C = utility_unknown_1040(4, var_0002)
    if var_000C < 30 then
        utility_unknown_1047(1, var_0002)
    end
end