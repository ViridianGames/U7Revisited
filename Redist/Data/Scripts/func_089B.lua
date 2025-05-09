--- Best guess: Manages a gargoyle-led combat training session, checking player strength and gold, enhancing physical prowess if conditions are met.
function func_089B(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    var_0002 = unknown_0920H()
    var_0003 = _GetPlayerName(var_0002)
    var_0004 = var_0002 == -356 and "your" or "their"
    if var_0002 == 0 then
        return
    end
    var_0005 = 3
    var_0006 = unknown_0922H(var_0005, var_0002, P0, P1)
    if var_0006 == 0 then
        add_dialogue("\"To be without the practical experience required to train at this time.\"")
    elseif var_0006 == 1 then
        var_0007 = unknown_0028H(-359, -359, 644, -357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0007 .. " gold altogether.")
        if var_0007 < P0 then
            add_dialogue("\"To need more gold than you have. To need 50 gold.\"")
            return
        end
    elseif var_0006 == 2 then
        add_dialogue("After examining " .. var_0004 .. " muscles, he says, \"To be stronger than I. To need no further training in combat.\"")
        return
    end
    var_0008 = unknown_002BH(true, -359, -359, 644, P0)
    add_dialogue("You pay " .. P0 .. " gold, and the training session begins.")
    var_0009 = var_0002 == -356 and "you begin" or var_0003 .. " begins"
    add_dialogue("The gargoyle begins with some intense weight-lifting which eventually leads to target practice with throwing axes. At the end, " .. var_0009 .. " to notice a change in physical prowess and hand-eye coordination.")
    var_000A = unknown_0910H(0, var_0002)
    if var_000A < 30 then
        unknown_0914H(1, var_0002)
    end
    var_000B = unknown_0910H(1, var_0002)
    if var_000B < 30 then
        unknown_0915H(1, var_0002)
    end
    var_000C = unknown_0910H(4, var_0002)
    if var_000C < 30 then
        unknown_0917H(1, var_0002)
    end
end